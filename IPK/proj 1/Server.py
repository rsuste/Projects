#!/usr/bin/python

import socket
import signal
import subprocess
import os
import sys
import time



class WEB_SERVER:
    def __init__(self,port = 12345):
        self.host = "localhost"
        self.port = port

    def server_start(self):
        """
        Funkce overi zda doslo k uspesnemu navazani spojeni se serverem, v pripade ze ne vyhodi chybu
        """
        self.socket = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
        try:
            self.socket.bind((self.host,self.port))
        except Exception as e:
            print("Nepodarilo se spojit se serverem\n")
            self.shutdown()
            sys.exit(1)

        print("Waiting for connection from hosts\n")
        print("You can shutdown server by CTRL+C\n")
        self._wait_for_connection()

    def shutdown(self):
        """
        Funkce se pokusi ukoncit spojeni se serverem pomoci socke.shutdown, pokud ovsem spojeni uz nebylo ukonceno
        v tom pripade vyhodi zpravu ze se nepodarilo ukoncit spojeni
        """
        try:
            Server.socket.shutdown(socket.SHUT_RDWR)
            print("Spojeni se serverem bylo ukonceno\n")
        except:
            print("Nepodarilo se ukoncit spojeni se serverem\n")

    def _load(self):
        """
        Funkce pocia load CPU ze soubouru /proc/stat dle vypoctu uvedenem zde: https://stackoverflow.com/questions/23367857/accurate-calculation-of-cpu-usage-given-in-percentage-in-linux
        :return: Vraci pocet procent vyuziti cpu v bytech
        """
        #nacte hodnoty
        file = open('/proc/stat').read().splitlines()
        result = file[0].split()
        user = result[1]
        nice = result[2]
        system = result[3]
        idle = result[4]
        iowait = result[5]
        irq = result[6]
        softirq = result[7]
        steal = result[8]

        #provede vypocet
        PrevIdle = float(idle) + float(iowait)
        PrevNonIdle = float(user) + float(nice) + float(system) + float(irq) + float(softirq) + float(steal)
        PrevTotal = PrevIdle + PrevNonIdle

        #pocka 1s
        time.sleep(1)

        #nacte nove hodnoty
        file = open('/proc/stat').read().splitlines()
        result = file[0].split()
        user = result[1]
        nice = result[2]
        system = result[3]
        idle = result[4]
        iowait = result[5]
        irq = result[6]
        softirq = result[7]
        steal = result[8]

        #provede vypocet novych hodnot
        Idle = float(idle) + float(iowait)
        NonIdle = float(user) + float(nice) + float(system) + float(irq) + float(softirq) + float(steal)
        Total = Idle + NonIdle

        #vypocte rozdily mezi hodnotami
        totald = Total - PrevTotal
        idled = Idle - PrevIdle

        #vypocita procentualni vyuziti z danych hodnot
        CPU_percentage = (totald - idled) / totald
        CPU_percentage *= 100
        return str(CPU_percentage).encode() + b" %"

    def _gen_headers(self,code):
        """
        Funkce prijme code na jehoz zakladu vygeneruje zpravnou HTML hlavicku
        :param code: obsahuje informaci o tom jaky kod ma byt vygenerovan
        :return: vraci hlavicku ve stringu
        """
        h= ""
        if (code ==200):
            h = 'HTTP/1.1 200 OK\n\n'
        elif (code == 404):
            h = 'HTTP/1.1 404 File not found error\n\n'
        elif (code == 405):
            h = 'HTTP/1.1 405 Method error\n\n'
        elif (code == 505):
            h = 'HTTP/1.0 505 Wrong version of HTTP \n\n'

        return h




    def _wait_for_connection(self):
        """
        Funkce ceka na prichozi spojeni od hosta ktere nasledne overi zda splnuje pozadovane parametry na zaklade cehoz
        vypise dany pozadavek na WEB-serveru v pripade ze parametry pozadavku nejsou spravne vypise chybovou hlasku
        """
        while True:
            print("\n\nCekam pripojeni hosta\n")
            self.socket.listen(5) #ceka na pripojeni hosta
            conn, addr = self.socket.accept() #prijme pripojeni
            #print("Spojeni navazano \n")
            data = conn.recv(1024) #prijem data
            receive = bytes.decode(data) #data prevede na string
            #print(receive)
            if len(receive.split()) > 0:
                receive = receive.split(' ') #data rozdeli do pole
                path = receive[1] #nacte cestu k souboru ktery je pozadovan
                method = receive[0] #nacte methodu ktera je volana
                htmlversion = receive[2] #nacte html verzi
            else:
                continue

            #overeni jednotlivych parametru co byly nacteny
            if (method == "GET") | (method == "HEAD"):
                if htmlversion != "HTML/1.1":
                    if path == "/hostname":
                        print("ukol 1\n")
                        result = subprocess.run(['hostname'], stdout=subprocess.PIPE) #nacte hostname z prikazoveho radku
                        result.stdout.decode('utf-8')
                        response_headers = self._gen_headers(200)
                        response_content = b'<head></head>'+result.stdout
                        #print(response_content)

                    elif path == "/cpu-name":
                        print("ukol 2\n")
                        if os.path.exists('/proc/cpuinfo'):
                            file_handler = open("/proc/cpuinfo").read().splitlines() #nacte cpu-name z /proc/cpuinfo
                            result = file_handler[4]
                            response_headers = self._gen_headers(200)
                            response_content = b'<head></head>'+result[13:].encode()+b'\n'
                        else:
                            print("Unknown path, file not found\n")
                            response_headers = self._gen_headers(404)
                            response_content = b"Error 404: File not found\n"

                    elif path == "/load":
                        print("ukol 3\n")
                        if os.path.exists('/proc/stat'):
                            response_headers = self._gen_headers(200)
                            response_content = b'<head></head>'+self._load()+b'\n' #vypocte load pomoci funkce _load()
                        else:
                            response_headers = self._gen_headers(404)
                            response_content = b"Error 404: File not found\n"

                    elif path[:-1] == "/load?refresh=":
                        print("ukol 4\n")
                        refresh = path[-1:]
                        if os.path.exists('/proc/stat'):
                            response_headers = self._gen_headers(200)
                            response_content = b'<head><meta http-equiv="refresh" content='+refresh.encode()+b'></head>'
                            response_content += self._load()+b'\n'

                        else:
                            response_headers = self._gen_headers(404)
                            response_content = b"Error 404: File not found\n"

                    else:
                        response_headers = self._gen_headers(404)
                        response_content = b"Error 404: File not found\n"


                else:
                    response_headers = self._gen_headers(505)
                    response_content = b"Error 505: Wrong HTML version\n"
            else:
                response_headers = self._gen_headers(405)
                response_content = b"Error 505: Wrong HTML method\n"


            server_response = response_headers.encode() #prevede hlavicku na bytes
            #print(server_response)
            server_response += response_content #ulozi obsah co se ma vypsat
            #print(server_response)
            conn.send(server_response) #dany obsah posle na server
            print("Closing connection with client")
            conn.close()

def graceful_shutdown(signalnum,handler):
    """
    Funkce ukonci webserver pomoci zkratky CTRL+C
    :param signalnum:
    :param handler:
    """
    print("\nByl zadan prikaz k ukonceni serveru\n")
    Server.shutdown()
    sys.exit(1)

signal.signal(signal.SIGINT,graceful_shutdown)

if len(sys.argv) == 2:
    #print(sys.argv[1].split("=")[1])
    Server = WEB_SERVER(int(sys.argv[1]))
elif len(sys.argv) > 2:
    print("Prilis argumentu \nStarting server on Default port\n")
    Server = WEB_SERVER()
else:
    Server = WEB_SERVER()

Server.server_start()





















