% ����ó���Լ�: Ÿ�̸� ����,udp socket close ��
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Research Professor @  Department of Biomedical Engineering, Hanyang University
% contact: 12cross@gmail.com
%---------------------------------------------------------------------
function myStop()
    global info;
    global bStarted;
    
    if ~isempty(timerfind)
        stop(timerfind);
    end
    bStarted =0;
%     closePreview(info.cam);
%     fclose(info.tcpipClient);
%     delete(info.tcpipClient);
%     clear all;

end