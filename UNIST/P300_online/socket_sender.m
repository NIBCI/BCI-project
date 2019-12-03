function socket_sender(adress,out)
   t = tcpip(adress, 1668, 'NetworkRole', 'client');
    fopen(t);
    output = int2str(out);
    
    fwrite(t, output, 'char') 
    fclose(t);
end