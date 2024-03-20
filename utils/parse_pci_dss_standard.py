import sys
import re
import os
import pdfplumber
import itertools

HEADER_TEMPLATE = """policy: PCI-DSS
title: Configuration Recommendations of a GNU/Linux System
id: pcidss_4
version: '4'
source: https://docs-prv.pcisecuritystandards.org/PCI%20DSS/Standard/PCI-DSS-v4_0.pdf
levels:
- id: base

controls:"""

REQ_INDEX_REGEX = '\w{0,1}[\d\.]*\d+\s'

class ComplianceControlNode:
    # pattern to split a parsed description from the pdf doc to a title and notes
    # intentionally ordered by length so the more specific is checked first
    title_split_patterns =[ r'([\S\n\s]*)including[,]* but not limited to failure of:\s*\n',
                            r'([\S\n\s]*)including[,]* but not limited to:\s*\n',
                            r'([\S\n\s]*)[,]* including mechanisms that are:\s*\n',
                            r'([\S\n\s]*)[,]* that meets the following:\s*\n',
                            r'([\S\n\s]*)[,]* code changes are:\s*\n',
                            r'([\S\n\s]*)[,]* that includes:\s*\n',
                            r'([\S\n\s]*)[,]* and includes:\s*\n',
                            r'([\S\n\s]*)[,]* and include:\s*\n',
                            r'([\S\n\s]*)[,]* as follows:\s*\n',
                            r'([\S\n\s]*)[,]* including:\s*\n',
                            r'([\S\n\s]*)[,]* such that:\s*\n',
                            r'([\S\n\s]*)[,]* are:\s*\n',
                            r'([\S\n\s]*)[,]* is:\s*\n',
                            r'([\S\n\s]*):\s*\n',
                            r'([\S\n\s]*)PCI DSS Reference:\s*']

    def __init__(self, title, root, parent_candidate):
        self.id = None
        if title != None:
            self.id = re.match(REQ_INDEX_REGEX, title)[0].strip()
        self.root = root
        self.depth = 0
        self.indent = '  ' # 2 spaces indentation
        self.set_title(title)    
        self.parent = self.choose_parent( parent_candidate )
        self.controls = []
        self.wrap_length = 98
        if self.parent != None:
            self.parent.add_subcontrol(self)
            self.depth = self.parent.depth + 1

    # drop notes separators from from description to get title
    def set_title(self, title_candidate):
        if title_candidate == None:
            return
        for splitter in ComplianceControlNode.title_split_patterns:
            title_match = re.match(splitter, title_candidate)
            if title_match == None:
                continue
            title_candidate = title_match[1]
            break
        self.title = re.sub("\n", "", title_candidate.strip()) # one line title
        self.title = re.sub(",$", ".", self.title) # should end with stop
        self.title = re.sub("^[A-Z0-9\.]+\s","",self.title) # id already has its field

    def add_subcontrol(self, node):
        self.controls.append(node)

    def get_id(self):
        return self.id

    def controls(self):
        return self.controls

    def is_child_of(self, parent_candidate_id):
        if parent_candidate_id in self.id:
            return True
        return False

    def choose_parent(self, parent_candidate):
        while True:
            if parent_candidate == None or \
               parent_candidate.get_id() == None:
                return self.root
            if parent_candidate.get_id() and \
               parent_candidate.get_id() in self.id:
                return parent_candidate
            parent_candidate = parent_candidate.parent

    def choose_next(self, visited):
        if len(self.controls) > 0 and not ( self.controls[0] in visited):
            return self.controls[0]
        current_idx = self.parent.controls.index(self)
        if current_idx+1 < len(self.parent.controls):
            return self.parent.controls[current_idx+1]
        elif self.parent.get_id() == None:
            return None
        else:
            return self.parent.choose_next(visited)

    def wrap_line(self, line,  indent_length):
        if not line:
            return ""
        extra_indent = indent_length+len("  title: ") 
        if (len(line) + extra_indent) <= self.wrap_length:
            return line
        wrap_line_length = self.wrap_length - extra_indent
        last_space = line[:wrap_line_length].rindex(' ')
        tail = line[(last_space+1):]
        line = line[:(last_space+1)]+"\n"+indent_length*" "+self.wrap_line(tail, indent_length)
        return line


    def print(self):
        print("%s- id: %s" % (self.indent*self.depth, self.id))
        print("%s  title: '%s'" % (self.indent*self.depth, self.wrap_line(self.title, (self.depth+2)*len(self.indent))))
        print("%s  levels: " % (self.indent*self.depth))
        print("%s    - base" % (self.indent*self.depth))
        print("%s  status: not applicable" % (self.indent*self.depth))
        if(len(self.controls) > 0):
            print("%s  controls:" % (self.indent*self.depth))
        else:
            print("%s  rules: []" % (self.indent*self.depth))
            print("")


class ComplianceControlTree:
    def __init__(self):
        self.root = ComplianceControlNode(None, None, None)
        self.last = self.root

    def add_node(self, req_title):
        self.last = ComplianceControlNode(req_title, self.root, self.last)

    def walk(self, hook):
        node = self.root
        visited = []
        while node != None:
            hook(node)
            visited.append(node)
            node = node.choose_next(visited)    

controlTree = ComplianceControlTree()
            
def extract_spec_tables(doc):
    # get all tables in the doc
    tbls = []
    for page in doc.pages:
        tbls.append(page.extract_tables())
    # drop empty elements
    filtered = filter(lambda el: el != [], tbls)
    tbls = list(filtered)
    # flatten the list of tables
    ftbls = list(itertools.chain(*tbls))
    return ftbls

# consider description any field bellow that is not 'Customized Approach Objective' or 'Applicability Notes' or 'Defined Approach Requirements '
def element_sub_column_name(doc_element_str):
    if not doc_element_str:
        return False
    ignore_strings = re.compile('(?:Customized Approach Objective|Applicability Notes|Defined Approach Requirements)')
    if ignore_strings.match(doc_element_str) == None:
        return False
    return True

# find requirement id starting point
def element_startw_with_req_idx(doc_element_str):
    if not doc_element_str:
        return False
    rq_idx_patternt = re.compile(REQ_INDEX_REGEX)
    if rq_idx_patternt.match(doc_element_str) == None:
        return False
    return True

# add new requirement to the list of already parsed ones
def update_list_req(list_req, req_index, doc_element):
    if not doc_element:
        return req_index
    if element_sub_column_name(str(doc_element)) == True :
        return req_index
    current_idx = len(list_req)
    if element_startw_with_req_idx(str(doc_element)) == True:
        req_index+=1
        list_req.append('')
    list_req[req_index] += str(doc_element)
    return req_index

if len(sys.argv) < 1:
    sys.exit("Please specify path to the PDF file to be processed!")

pci_dss_pdf = os.path.realpath(sys.argv[1])

# open the input
try:
    pdfdox =  pdfplumber.open(pci_dss_pdf)
except:
    sys.exit("Not valid PDF passed as input!")
    
spec_tbls = extract_spec_tables(pdfdox)


# for every table with column 'Requirements and Testing Procedures', get the column index and consider title the first field of same column starting with decimal-doted number
list_req = []
tbl_count = 0
req_index = -1
for tbl in spec_tbls:
    index = -1
    for el in tbl:
       if( index == -1):
           try:
               index = el.index('Requirements and Testing Procedures')
           except:
               pass
       else:
           req_index = update_list_req(list_req, req_index, el[index])
    tbl_count += 1

for reqs in list_req:
    controlTree.add_node(reqs)

def print_node(node):
    if node.get_id():
        node.print()
    else:
        print(HEADER_TEMPLATE)
    
controlTree.walk(print_node)
