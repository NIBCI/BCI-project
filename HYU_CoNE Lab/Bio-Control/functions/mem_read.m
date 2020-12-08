function mem_read
%     persistent time_cur;
%     a = datevec(now);
%     disp(a(6)-time_cur);
%     time_cur = a(6);
    global mem_dataqueue;
    
    global timer_mem_read_test;
    
    if mem_dataqueue.bReceving.Data~=1
        stop(timer_mem_read_test);
    end
    d = reshape(mem_dataqueue.data.Data,[8,5120])';
    veog = d(:,4) - d(:,3);
    veog = veog - veog(1);
    heog = d(:,2) - d(:,1);
    heog = heog - heog(1);
    plot(veog);
    %hold on;
    %plot(heog);
    hold off;
    l.x = [mem_dataqueue.index_start.Data, mem_dataqueue.index_start.Data];
    l.y = get(gca,'YLim');
    line(l.x, l.y);
end