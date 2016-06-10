% Red Threshold & G/R Ratio [Izaya] : 

%Crop standardized images
fnames=fieldnames(dirstruct)
for i=1:length(fnames)
    oname=[fnames{i},'_adj_crop=imcrop(',fnames{i},'_adj,',fnames{i},'_crop_rect);']
    eval(oname);
end

%Crop non-standardized images
fnames=fieldnames(dirstruct)
for i=1:length(fnames)
    oname=[fnames{i},'_crop=imcrop(',fnames{i},',',fnames{i},'_crop_rect);']
    eval(oname);
end

%% Bring all 12 into one 12000 array
all_tvals=[];
all_rgb=[];
all_rgb_adj=[];
for f=1:length(fnames)
I=evalin('base',[fnames{f},adj,'_crop;']);
Iadj=evalin('base',[fnames{f},'_adj_crop;']);
tvals=evalin('base',[fnames{f},'_crop_targ;']);
clear cvals
for i=1:100
x=tvals(i,2);
y=tvals(i,1);
rgb(i,:)=I(x,y,:);
rgb_adj(i,:)=Iadj(x,y,:);
end
rgb=double(rgb);
rgb_adj=double(rgb_adj);
all_tvals=[all_tvals;tvals(:,3)];
all_rgb_adj=[all_rgb_adj; rgb_adj];
all_rgb=[all_rgb;rgb];
end

%% ORIGINAL
stats=[]
adj=''%'_adj';%''
%best 300, 1.005
thresh=[300, 300, 300; 1.005,1.004,1.003];
for q=1:1
all_tvals=[];
all_cvals=[];
all_rgb=[];
for f=1:length(fnames)
%Read in Image and Image Filename
%Rearrange Image Matrix so instead of Rows X Cols X Band, it is now 3
%columns (for the 3 bands) with the number of rows equal to the num. of
%pixels.
cutSum=thresh(1,q);%310;%321
cutRatio=thresh(2,q);%1.01;%1.05
I=eval([fnames{f},adj,'_crop;']);
clear RowS RowAll
for i=1:3
RowS=I(:,:,i);
RowAll(:,i)=double(RowS(:));
end
%Create R,G, and B variables
R=RowAll(:,1);
G=RowAll(:,2);
B=RowAll(:,3);
%Apply THRESHOLD VALUES
%Green to Red Ratio
ratioGR=G./R;  
ratioGR(find(ratioGR==Inf))=0; %for case where R=0 and ratio blows up
%Sum all RGB values 
sumRGB=sum(RowAll,2);
%Output Classification
%NPV=1, SHADE=2, GV=3
yout=R*0+2; %create output array with default value of 2 (Shade).
%Apply Thresholds, 1st apply sumRGB then ratioGR so ratioGR trumps
yout(sumRGB>cutSum)=1;
yout(ratioGR>cutRatio)=3;
yout(B>G+40 & R>160)=4; %Blue Flowers
yout(R./B>1.8 & G./B>1.8 & R+G>400)=5; %YELLOW FLOWERS **change**
%yout(sumRGB<100)=2; %150**change** make very dark shade?
%Format Output
szImg=size(RowS);
m=szImg(1);
n=szImg(2);
yout=reshape(yout,m,n);
eval([fnames{f},adj,'_crop_class=yout;']);


%fname='DSCN9429_adj_crop'
I=evalin('base',[fnames{f},adj,'_crop;']);
cI=evalin('base',[fnames{f},adj,'_crop_class;']);
tvals=evalin('base',[fnames{f},'_crop_targ;']);
clear cvals

for i=1:100
x=tvals(i,2);
y=tvals(i,1);
cvals(i)=cI(x,y);
rgb(i,:)=I(x,y,:);
end
rgb=double(rgb);

pa=length(find(tvals(:,3)==cvals'))
all_pa(f)=pa;
all_tvals=[all_tvals;tvals(:,3)];
all_cvals=[all_cvals;cvals'];
all_rgb=[all_rgb;rgb];
end


%Evaluation
pa=length(find(all_tvals==all_cvals))
figure
subplot(1,2,1)
hist3([all_cvals,all_tvals],{1:5 1:5})
xlabel('Auto. Class','FontWeight','Bold','Color','w')
ylabel('Target Class','FontWeight','Bold','Color','k')
subplot(1,2,2)
cbar=hist(all_cvals,1:5);
tbar=hist(all_tvals,1:5);
bar([tbar',cbar'])
set(gca,'XTickLabel',{'1-NPV','2-SHD','3-GV','4-FlBl','5-FlYe'})
colormap gray
legend('Target','Auto.')
set(gcf,'Position',[1 1 800 350])
title(['Accuracy:',num2str(pa/length(all_tvals))])

disp('donzo')
pa_out=length(find(all_tvals==all_cvals))
stats(q,:)=[cutSum, cutRatio, min(all_pa),max(all_pa),mean(all_pa),pa_out/length(all_tvals)]
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
%% IZAYA
stats=[]
%best 300, 1.005
thresh=[75, 85, 95; 1.003,1.003,1.003];
for q=1:3
all_tvals=[];
all_cvals=[];
all_rgb=[];
for f=1:length(fnames)
%Read in Image and Image Filename
%Rearrange Image Matrix so instead of Rows X Cols X Band, it is now 3
%columns (for the 3 bands) with the number of rows equal to the num. of
%pixels.
cutSum=thresh(1,q);%310;%321
cutRatio=thresh(2,q);%1.01;%1.05
I=eval([fnames{f},'_adj_crop;']);
clear RowS RowAll
for i=1:3
RowS=I(:,:,i);
RowAll(:,i)=double(RowS(:));
end
%Create R,G, and B variables
R=RowAll(:,1);
G=RowAll(:,2);
B=RowAll(:,3);
%Apply THRESHOLD VALUES
%Green to Red Ratio
ratioGR=G./R;  
ratioGR(find(ratioGR==Inf))=0; %for case where R=0 and ratio blows up
%Sum all RGB values 
sumRGB=sum(RowAll,2);
%Output Classification
%NPV=1, SHADE=2, GV=3
yout=R*0+1; %create output array with default value of 1 (NPV+Soil).
%Apply Thresholds, 1st apply GV then shadow since shadow will trump
yout(ratioGR>cutRatio & ratioGR<5)=3;
yout(R<cutSum)=2;

%yout(B>G+40 & R>160)=4; %Blue Flowers
%yout(R./B>1.8 & G./B>1.8 & R+G>400)=5; %YELLOW FLOWERS **change**
%yout(sumRGB<100)=2; %150**change** make very dark shade?
%Format Output
szImg=size(RowS);
m=szImg(1);
n=szImg(2);
yout=reshape(yout,m,n);
eval([fnames{f},'_adj_crop_class=yout;']);


%fname='DSCN9429_adj_crop'
I=evalin('base',[fnames{f},'_adj_crop;']);
cI=evalin('base',[fnames{f},'_adj_crop_class;']);
tvals=evalin('base',[fnames{f},'_crop_targ;']);
clear cvals

for i=1:100
x=tvals(i,2);
y=tvals(i,1);
cvals(i)=cI(x,y);
rgb(i,:)=I(x,y,:);
end
rgb=double(rgb);

pa=length(find(tvals(:,3)==cvals'))
all_pa(f)=pa;
all_tvals=[all_tvals;tvals(:,3)];
all_cvals=[all_cvals;cvals'];
all_rgb=[all_rgb;rgb];
end


%Evaluation
pa=length(find(all_tvals==all_cvals))
figure
subplot(1,2,1)
hist3([all_cvals,all_tvals],{1:5 1:5})
xlabel('Auto. Class','FontWeight','Bold','Color','w')
ylabel('Target Class','FontWeight','Bold','Color','k')
subplot(1,2,2)
cbar=hist(all_cvals,1:5);
tbar=hist(all_tvals,1:5);
bar([tbar',cbar'])
set(gca,'XTickLabel',{'1-NPV','2-SHD','3-GV','4-FlBl','5-FlYe'})
colormap gray
legend('Target','Auto.')
set(gcf,'Position',[1 1 800 350])
title(['Accuracy:',num2str(pa/length(all_tvals))])

disp('donzo')
pa_out=length(find(all_tvals==all_cvals))
stats(q,:)=[cutSum, cutRatio, min(all_pa),max(all_pa),mean(all_pa),pa_out/length(all_tvals)]
end

%% TREE CLASSIFICATION
% Classification Trees (adjusted values)
% X from Adj and Non-Adj. Images
ratioGR=all_rgb_adj(:,2)./all_rgb_adj(:,1);
sumRGB=sum(all_rgb_adj,2);
x_adj=[all_rgb_adj,ratioGR,sumRGB];
ratioGR=all_rgb(:,2)./all_rgb(:,1);
sumRGB=sum(all_rgb,2);
x=[all_rgb,ratioGR,sumRGB];
y=all_tvals;
t_adj=treefit(x_adj,y,'method','classification');
t0_adj = treeprune(t_adj,'level',15);
treedisp(t0_adj,'name',{'r','g','b','g/r','sumRGB'});
t=treefit(x,y,'method','classification');
t0 = treeprune(t,'level',15);
treedisp(t0,'name',{'r','g','b','g/r','sumRGB'});
treeOut_x_0=treeval(t0,x);
treeOut_xadj_0adj=treeval(t0_adj,x_adj);
treeOut_xadj_0=treeval(t0,x_adj);
treeOut_x_0adj=treeval(t0_adj,x);
tlen=[length(find(treeOut_x_0==y)), length(find(treeOut_xadj_0adj==y)),...
    length(find(treeOut_xadj_0==y)),length(find(treeOut_x_0adj==y))];
tlen/length(y)

%%
% Classification Trees (adjusted values)
ratioGR=all_rgb(:,2)./all_rgb(:,1);
sumRGB=sum(all_rgb,2);
x=[all_rgb,ratioGR,sumRGB];
y=all_tvals;
t=treefit(x,y,'method','classification');
t0 = treeprune(t,'level',15);
treedisp(t0,'name',{'r','g','b','g/r','sumRGB'});
treeOut=treeval(t0,x);
length(find(treeOut==y))/length(y)
treeOut=treeval(t0_adj,x);
length(find(treeOut==y))/length(y)


%% TESTING
%% Bring last ones into one testing array
all_tvals_test=[];
all_rgb_test=[];
all_rgb_adj_test=[];
for f=1:length(fnames)
I=evalin('base',[fnames{f},adj,'_crop;']);
Iadj=evalin('base',[fnames{f},'_adj_crop;']);
tvals=evalin('base',[fnames{f},'_crop_targ;']);
clear cvals
for i=1:100
x=tvals(i,2);
y=tvals(i,1);
rgb(i,:)=I(x,y,:);
rgb_adj(i,:)=Iadj(x,y,:);
end
rgb=double(rgb);
rgb_adj=double(rgb_adj);
all_tvals_test=[all_tvals_test;tvals(:,3)];
all_rgb_adj_test=[all_rgb_adj_test; rgb_adj];
all_rgb_test=[all_rgb_test;rgb];
end
%% Testing Tree Class
ratioGR=all_rgb_adj_test(:,2)./all_rgb_adj_test(:,1);
sumRGB=sum(all_rgb_adj_test,2);
x_adj_test=[all_rgb_adj_test,ratioGR,sumRGB];
ratioGR=all_rgb_test(:,2)./all_rgb_test(:,1);
sumRGB=sum(all_rgb_test,2);
x_test=[all_rgb_test,ratioGR,sumRGB];
y=all_tvals_test;
treeOut_x_0=treeval(t0,x_test);
treeOut_xadj_0adj=treeval(t0_adj,x_adj_test);
treeOut_xadj_0=treeval(t0,x_adj_test);
treeOut_x_0adj=treeval(t0_adj,x_test);
tlen=[length(find(treeOut_x_0==y)), length(find(treeOut_xadj_0adj==y)),...
    length(find(treeOut_xadj_0==y)),length(find(treeOut_x_0adj==y))];
tlen/length(y)

%%
x=treeOut_x_0;
y=all_tvals_test;
figure
subplot(1,2,1)
hist3([x,y],{1:5 1:5})
xlabel('Auto. Class','FontWeight','Bold','Color','w')
ylabel('Target Class','FontWeight','Bold','Color','k')
subplot(1,2,2)
cbar=hist(x,1:5);
tbar=hist(y,1:5);
bar([tbar',cbar'])
set(gca,'XTickLabel',{'1-NPV','2-SHD','3-GV','4-FlBl','5-FlYe'})
colormap gray
legend('Target','Auto.')
set(gcf,'Position',[1 1 800 350])
title(['Accuracy:',num2str(length(find(x==y))/length(y))])

%% FIGURES
%NPV, Shade, GV Figure
imgnum=16;
ymatrix=reshape(y,100,imgnum);
xmatrix=reshape(x,100,imgnum);
figure
subplot(2,2,1)
h=hist(ymatrix,1:5)
bar(h)
set(gca,'XTickLabel',{'1-NPV','2-SHD','3-GV','4-FlBl','5-FlYe'})
title('Target Classification - By Class')
subplot(2,2,2)
hplt=bar(h')
colortxt={[.9 .9 .9],[0 0 0],[0 1 0],[0 0 1],[1 1 0]}
for i=1:5
set(hplt(i),'FaceColor',colortxt{i})
end
legend({'1-NPV','2-SHD','3-GV','4-FlBl','5-FlYe'})
title('Target Classification - By Image')
subplot(2,2,3)
h=hist(xmatrix,1:5)
bar(h)
set(gca,'XTickLabel',{'1-NPV','2-SHD','3-GV','4-FlBl','5-FlYe'})
title('Auto Classification - By Class')
subplot(2,2,4)
hplt=bar(h')
colortxt={[.9 .9 .9],[0 0 0],[0 1 0],[0 0 1],[1 1 0]}
for i=1:5
set(hplt(i),'FaceColor',colortxt{i})
end
title('Auto Classification - By Image')

figure
hx=hist(xmatrix,1:5);
hy=hist(ymatrix,1:5);
for i=1:imgnum
    subplot(4,4,i)
    bar([hy(:,i),hx(:,i)])
    colormap gray
    ylim([0 100])
    title([fnames{i},':',num2str(length(find(xmatrix(:,i)==ymatrix(:,i))))])
end
legend({'target','auto'})