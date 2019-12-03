function badch = prebadchannelrejection(sig,param)
  cs_sig          = filtfilt(param.pBF{1}, param.pBF{2}, double(sig)')';
                CC = zeros(param.NumCh,param.NumCh);
                for ch1 = 1 : param.NumCh - 1
                    for ch2 = ch1 + 1 : param.NumCh
                        CC(ch1,ch2) = corr(cs_sig(ch1,:)', cs_sig(ch2,:)');
                    end
                    fprintf('*');
                end
                fprintf('\n');
                thr                 = triu(CC < 0.4);
                badch = [];
                for ch1 = 1 : (param.NumCh-1)
                    if sum(thr(ch1,ch1+1:end))/(param.NumCh-ch1) > 0.7
                        badch = [badch ; ch1];
                    end
                end
                for ch2 = 2 :param.NumCh 
                    if sum(thr(1:ch2-1,ch2))/(ch2-1) > 0.7
                        sum(thr(1:ch2-1,ch2))/(ch2-1);
                        badch = [badch ; ch2];
                    end
                end
                badch = unique(badch);
                %%%%%%%%%%% For draw a figure %%%%%%%%%%%%%
                %    for i = 1:param.NumCh
                %        CC(i,i) = 1;
                %    end
                %
                %    for i = 2:param.NumCh
                %        for j = 1:i-1
                %            CC(i,j) = NaN;
                %        end
                %    end
                %    figure; pcolor(CC); colormap jet
                %    shading flat;
                %    set(gca,'ydir','reverse');
                %    colorbar
                %    xlabel('Channel'); ylabel('Channel'); title('Correlation of Channels (Subject 17)','FontSize',30)
                %    set(gca,'XTick',1:param.NumCh,'YTick',1:param.NumCh,'YTickLabel',param.Ch,'XTickLabel',param.Ch,...
                %         'XTickLabelRotation',90, 'TickLength',[0 0],'FontSize', 20)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                figure(2); imagesc(CC);colormap jet