#!/usr/bin/python

import sys, os 

header = '''<fix-group id="bash" system="urn:xccdf:fix:script:sh" xmlns="http://checklists.nist.gov/xccdf/1.1">\n'''
footer = '</fix-group>\n'

def encode(text):
    text = text.replace('&','&amp;')
    text = text.replace('>','&gt;')
    text = text.replace('<','&lt;')
    return text

def main():
    if len(sys.argv) < 2:
        print "Provide a directory name, which contains the fixes."
        sys.exit(1)
        
    fixDir = sys.argv[1]
    output = sys.argv[2]
    out = open(output,'w')
    out.write(header)
    for filename in os.listdir(fixDir):
        if filename.endswith(".sh"):
            body = ""
            with open( fixDir + "/" + filename, 'r') as f:
                body = body + encode(f.read())
            fixName = os.path.splitext(filename)[0]
            out.write("<fix rule=\""+fixName+"\">\n")
            out.write(body+"\n")
            out.write("</fix>\n")

    out.write(footer)
    sys.exit(0)
        
if __name__ == "__main__":
    main()
