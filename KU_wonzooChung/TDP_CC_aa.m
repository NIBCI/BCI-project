clear all
load('data_set_IVa_av');
load('true_labels_av');
cnt= 0.1*double(cnt);
cue=mrk.pos;
yy=mrk.y;
cue=transpose(cue);
temp=[];
cnt=cnt;
numt=84;
for k=1:numt
    temp=cnt(cue(k):cue(k)+500,:);
    temp=temp';
    eeg(:,:,k)=temp;
    temp=0;
end
u=1;
for k=numt+1:280
    temp=cnt(cue(k):cue(k)+500,:);
    temp=temp';
    ee3(:,:,u)=temp;
    u=u+1;
    temp=0;
end
st=1;
stt=1;
for k=1:numt
    if mrk.y(k)==1
        ll(st)=k;
        st=st+1;
    else
        rr(stt)=k;
        stt=stt+1;
    end
end
l=length(ll);
r=length(rr);
free=min(l,r)-1;
tr=280-numt;
for k=1:l
    ee1(:,:,k)=eeg(:,:,ll(k));
end
for k=1:r
    ee2(:,:,k)=eeg(:,:,rr(k));
end
n_ch=18;
chn=[50,43,44,52,53,60,61,89,54,91,55,47,48,56,58,64,65,93];
for k=1:n_ch
    e11(k,:,:)=ee1(chn(k),:,:);
    e22(k,:,:)=ee2(chn(k),:,:);
    e33(k,:,:)=ee3(chn(k),:,:);
end    
 zq=0;
 for q=0:0.05:0
     for qq=1:1
  [bbb,aaa]=butter(5,[(1.5)/50 (40)/50]); 

         zq=zq+1;
         n_ec1=[];
         n_ec2=[];
         n_ec3=[];
        for node=1:n_ch
            for k=1:l
                ect1(k,:)=filtfilt(bbb,aaa,e11(node,:,k));
            end
            n_ec1(:,:,node)=(ect1(:,45+6:250));
            for k=1:r
                ect2(k,:)=filtfilt(bbb,aaa,e22(node,:,k));
            end
            n_ec2(:,:,node)=(ect2(:,45+6:250));
            for k=1:tr
                ect3(k,:)=filtfilt(bbb,aaa,e33(node,:,k));
            end
            n_ec3(:,:,node)=(ect3(:,45+6:250));
        end
        
%  mk=ok
c_1=[];
c_2=[];
temp=[];
for k=1:l
    temp(:,:)=n_ec1(k,:,:);
    c_1(k,:,1)=log(var(temp));
    c_1(k,:,2)=log(var(diff(temp)));
    c_1(k,:,3)=log(var(diff(diff(temp))));
end
temp=[];
for k=1:r
    temp(:,:)=n_ec2(k,:,:);
    c_2(k,:,1)=log(var(temp));
    c_2(k,:,2)=log(var(diff(temp)));
    c_2(k,:,3)=log(var(diff(diff(temp))));
end
f_t1=mean(c_1(:,:,1))-mean(c_2(:,:,1));
f_t2=mean(c_1(:,:,2))-mean(c_2(:,:,2));
f_t3=mean(c_1(:,:,3))-mean(c_2(:,:,3));
f_d1=mean(c_1(:,:,1))+mean(c_1(:,:,2))+mean(c_1(:,:,3));
f_d2=mean(c_2(:,:,1))+mean(c_2(:,:,2))+mean(c_2(:,:,3));
[fd1,fd2]=max(f_d1-f_d2);
[ffd1,ffd2]=min(f_d1-f_d2);

f4=(((mean(c_1(:,:,1))-mean(c_2(:,:,1)) ).^2)+((mean(c_1(:,:,2))-mean(c_2(:,:,2)) ).^2)+((mean(c_1(:,:,3))-mean(c_2(:,:,3)) ).^2));
f5=((var(c_1(:,:,1))+var(c_2(:,:,1)))+(var(c_1(:,:,2))+var(c_2(:,:,2)))+(var(c_1(:,:,3))+var(c_2(:,:,3))));
f_tdp1=f4./f5;
[d1,d2(zq)]=max(f_tdp1);
[w1,w2]=sort(f_tdp1,'descend');
%%
for trial=1:l
    for kk=1:n_ch
        for k=1:n_ch
            cc_r=cov(n_ec1(trial,:,kk),n_ec1(trial,:,k));
            cc_rc1=cc_r;
            cc_rr=cc_rc1(2)/sqrt(cc_rc1(1,1)*cc_rc1(2,2));%(std(n_ec1(trial,:,kk))*std(n_ec1(trial,:,k)) );
            cc_rr_e1(kk,k,trial)=cc_rr;
        end
    end
end
for trial=1:r
    for kk=1:n_ch
        for k=1:n_ch
            cc_r2=cov(n_ec2(trial,:,kk),n_ec2(trial,:,k));
            cc_rc2=cc_r2;
            cc_rr2=cc_rc2(2)/sqrt(cc_rc2(1,1)*cc_rc2(2,2));
            cc_rr_e2(kk,k,trial)=cc_rr2;
        end
    end
end
m_1=abs(mean(cc_rr_e1,3));
m_2=abs(mean(cc_rr_e2,3));
kl=0;
rre=[];
for kz=1:1
    k=w2(kz);
    tem1=m_1(k,:);
    tem1(tem1<(0.6+q))=0;
    tem2=m_2(k,:);
    tem2(tem2<(0.6+q))=0;
    tem3=tem1.*tem2;
    reg=[];
    reg=find(tem3>0);
    if length(reg)>1
        kl=kl+1;
        rre{kl}=reg;
    end
    if length(reg)<=1
        apa=k;
    end
end
kl=0;
for kz=2:2
    k=w2(kz);
    ttem1=m_1(k,:);
    ttem1(ttem1<(0.6+q))=0;
    ttem2=m_2(k,:);
    ttem2(ttem2<(0.6+q))=0;
    ttem3=ttem1.*ttem2;
    regg=[];
    regg=find(ttem3>0);
    if length(regg)>1
        kl=kl+1;
        rrre{kl}=regg;
    end
    if length(regg)<=1
        apa=k;
    end
end
r3=rre{1};
r4=rrre{1};
r1=unique([r3,r4]);
r2{zq}=r1;
% r1=[1:18];
ji=0;
chs=0;
for si=4:4:32
    chs=chs+1;
    fsz=4;
    ji=ji+1;
    jji=0;
    for ssi=si+4:si+4
        jji=jji+1;
        [bbb,aaa]=butter(5,[si/50 ssi/50]);
        f1=[];c_f1=[];f2=[];c_f2=[];f3=[];c_f3=[];vf=[];vft=[];tf_ec1=[];tf_ec2=[];tf_ec3=[];
        cro1=[];cro2=[];cro3=[];c2ro1=[];c2ro2=[];c2ro3=[];mask_1=[];mask_2=[];mask_3=[];result=[];stemp=[];fe1=[];fe2=[];fe3=[];result1=[];stemp=[];sstemp=[];
        ssstemp=[];co1=[];co2=[];co3=[];max_f_l=[];max_f_r=[];max_f_t=[];min_f_l=[];min_f_r=[];min_f_t=[];tlcsp=[];trcsp=[];ttcsp=[];V=[];Va=[];VV=[];
        for node=1:n_ch
            for k=1:l
                ect1(k,:)=filtfilt(bbb,aaa,e11(node,:,k));
            end
            n_ec1_{ji,jji}(:,:,node)=(ect1(:,51:250));
            for k=1:r
                ect2(k,:)=filtfilt(bbb,aaa,e22(node,:,k));
            end
            n_ec2_{ji,jji}(:,:,node)=(ect2(:,51:250));
            for k=1:tr
                ect3(k,:)=filtfilt(bbb,aaa,e33(node,:,k));
            end
            n_ec3_{ji,jji}(:,:,node)=(ect3(:,51:250));
        end
    end
    %% re1
    for ua=1:1
        for op=chs:chs
            for oop=1:jji
                [re_l_{op,oop,ua},re_r_{op,oop,ua},re_t_{op,oop,ua},re_d_{op,oop,ua},re_d1_{op,oop,ua},re_d2_{op,oop,ua}]=ppyk2_3(l,r,tr,n_ec1_{op,oop}(:,:,r1),n_ec2_{op,oop}(:,:,r1),n_ec3_{op,oop}(:,:,r1));
            end
        end
        
        [dr1{ua},ddr1{ua}]=sel3_aw(re_l_,re_r_,numt,chs,jji,l,r,ua);
        [fl{ua},fr{ua},ft{ua},do{ua},fs{ua}]=fea_sel4(re_l_,re_r_,re_t_,re_d_,ddr1{ua},jji,chs,ua);
        mi{ua}(chs,:)=dr1{ua};
        mii{ua}(chs,:)=ddr1{ua};
        lcsp{ua}(:,:,chs)=[fl{ua}];
        rcsp{ua}(:,:,chs)=[fr{ua}];
        tcsp{ua}(:,:,chs)=[ft{ua}];
        dif_t{ua}(chs,:)=[do{ua}];
    end
end
for k=1:1
    [ffl{k},ffr{k},fft{k},ddo{k}]=ega(mi{k},lcsp{k},rcsp{k},tcsp{k},dif_t{k});
    eig_d(k)=ddo{k};
end
clcsp=ffl{1};
crcsp=ffr{1};
ctcsp=fft{1};
vf=[clcsp;crcsp];
lvf=[ones(l,1);ones(r,1)+1];
lvf=[ones(l,1);ones(r,1)+1];
options.MaxIter = 100000;
mdl=fitcsvm(vf,lvf);
tvl=true_y(numt+1:end);
[result1,sco]= predict(mdl,ctcsp);
correct1=0;
for k=1:length(result1)
    if result1(k)==tvl(k)
        correct1=correct1+1;
    end
end

aaccy1(zq)=correct1/length(result1)*100;
     end
 end
