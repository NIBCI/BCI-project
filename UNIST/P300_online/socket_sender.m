function socket_sender(adress,port,out)
% �ֽ� ���� (2020) port: 1668
% BS�� ���� (2018) port: 23
   t = tcpip(adress, port, 'NetworkRole', 'client');
    fopen(t);
    output = int2str(out);
    
    fwrite(t, output, 'char') 
    fclose(t);
end