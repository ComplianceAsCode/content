#!/usr/bin/env python3
 
import sys
import os
import argparse
import json
 
import ssg.rules
import ssg.utils
import ssg.rule_yaml

from pathlib import Path
 
SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

#script en sucio de prueba
#Este script crea un perfil para el producto deseado con el nombre especificado a partir de una lista de reglas
#Ejemplo de uso(quitar comillas): utils/add_profile_from_list.py 'ruta_archivo_con_lista_de_reglas' 'sle11' 'nombre_perfil'
 
def main():
 
    with open(sys.argv[1], 'r') as file:
        product = sys.argv[2]
        name = sys.argv[3]
        ruleArray = file.readlines()
        ruleArray = [x.strip() for x in ruleArray]

    path = Path("./{}/profiles/{}.profile".format(product,name))

    with open(path, 'w+') as f:
        f.write("documentation_complete: true\n"+"\n"+"title: '{}'\n".format(name)+"\n"+"description: |- \n"+"    Write the profile description here\n"+"\n"+"selections:\n") 	
        for rule in ruleArray:
            if rule != "":
                f.write("    - {}\n".format(rule))

 
if __name__ == "__main__":
        main()

