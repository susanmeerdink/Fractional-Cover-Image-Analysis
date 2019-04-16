%% Image Analysis Script
% This is code batch processes images for fractional cover.
% Does NOT allow for cropping of images right now. 

%%%USER INPUTS%%%%%%%%%%%%%%%
folder = 'C:\Users\susanmeerdink\Dropbox (UFL)\Dennison_Frac_Cover_Project\Photos_to_Process\012812\';
ext = 'CR2';
outputFile = 'C:\Users\susanmeerdink\Dropbox (UFL)\Dennison_Frac_Cover_Project\Photos_to_Process\fractional_cover_stats_012812.csv';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filelist = dir(strcat(folder, '*.', ext));
versionTest = version('-release');
load('tree.mat')
load('treeUpdated.mat')
fractions = zeros(size(filelist,1),6);

% Loop through files
for n = 1:size(filelist,1)
    I = imread(strcat(filelist(n).folder, '\', filelist(n).name));
    [~,filename,ext] = fileparts(char(filelist(n).name)); %set the original file name and extension
    
    %Apply Tree
    for j = 1:3
        RowS = I(:,:,j);
        all_rgb(:,j) = double(RowS(:));
    end
    ratioGR = all_rgb(:,2)./all_rgb(:,1);
    sumRGB = sum(all_rgb,2);
    data = [all_rgb,ratioGR,sumRGB];
    
    if str2num(versionTest(1:4)) < 2016
        treeOut_x_0 = treeval(t0,data);
        %Warning: treefit will be removed in a future release. Use the predict method of an object returned by fitctree or fitrtree instead.
    else
        treeOut_x_0 = predict(tree,data);
    end
    
    R = all_rgb(:,1);
    G = all_rgb(:,2);
    B = all_rgb(:,3);
    treeOut_x_0(B > G + 40 & R > 160) = 4; %Blue Flowers
    treeOut_x_0(R./B > 1.8 & G./B > 1.8 & R + G > 400) = 5; %YELLOW FLOWERS
    fractions(n,:) = horzcat(n,hist(treeOut_x_0,1:5)/length(sumRGB));
    %Column Organization: index of fileInfo, Percentages of NPV, Shade, GV, Blue Flowers, Yellow Flowers
    
    %Create Figure
    szImg=size(RowS);
    m=szImg(1);
    nn=szImg(2);
    yout = reshape(treeOut_x_0,m,nn);
    
    %DISPLAY CLASSIFICATION RESULTS
    figure('units','normalized','outerposition',[0 0 1 0.75],'visible','off')
    subplot(1,3,1)%Original Image
    hold on
    title([filename,' Original'],'Interpreter','none')
    imagesc(I)
    axis square; axis off
    hold off
    
    subplot(1,3,2) %Classification
    hold on
    title([filename, ' Classification'],'Interpreter','none')
    im = imagesc(yout);%Display image with scaled colors
    cmap = [1 1 1; 0 0 0; 0 1 0; 0 0 1; 1 1 0]; %colormap: white, black, green, [Blue, Yellow]
    set(gca,'CLim',[1 5])
    colormap(cmap)
    axis square; axis off
    hold on
    
    subplot(1,3,3) %ColorBar
    hold on
    ytlabel={[num2str(100*fractions(n,2),2),'% Non-Photosynthetic Vegetation'],...
        [num2str(100*fractions(n,3),2),'% Shade'],...
        [num2str(100*fractions(n,4),2),'% Green Vegetation'],...
        [num2str(100*fractions(n,5),2),'% Blue Flowers'],...
        [num2str(100*fractions(n,6),2),'% Yellow Flowers']};
    
    if str2num(versionTest(1:4)) > 2014
        %Only works for MATLAB 2015 or newer
        colorbar('Location','west',...
            'Ticks',[0.1, 0.3, 0.5, 0.7, 0.9],...
            'FontSize',14,...
            'TickLabels',ytlabel)
    else
        %For older versions of matlab (tested on 2013)
        colorbar('Location','west','YTick',[0.1:0.2:0.9])
        text(0.1,0.1, ytlabel(1),'FontSize',14)
        text(0.1,0.3, ytlabel(2),'FontSize',14)
        text(0.1,0.5, ytlabel(3),'FontSize',14)
        text(0.1,0.7, ytlabel(4),'FontSize',14)
        text(0.1,0.9, ytlabel(5),'FontSize',14)
    end
    axis off
    hold off
    
    %SAVE CLASSIFICATION IMAGE TO CLASSIFICATION FOLDER
    cflder = strcat(filelist(n).folder, '\Classification\');
    if isdir(cflder)== 0 %If the directory doesn't exist make it
        mkdir(cflder)
    end
    fname = strcat(cflder,filename,'_class.jpg');
    imwrite(yout,cmap,fname);
    saveas(gca, strcat(cflder,filename,'_classfractions.jpg'))

end

% SAVE FRACTIONAL COVER RESULTS
fid = fopen(outputFile,'w');
fprintf(fid,'Filename,NPV,Shade,GV,Flower Blue, Flower Yellow\n');
for i = 1:size(fractions,1)
    fprintf(fid,'%s%s',char(filelist(i).name),',');
    fprintf(fid,'%f ,%f,%f,%f,%f,\n',fractions(i,2:6)); %Classification Values (5 vals, cell 5)
end
fclose(fid);
disp('Completed processing fractional cover.')