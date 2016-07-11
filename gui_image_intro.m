function varargout = gui_image_intro(varargin)
% ---To Do:
%    1.) Need to refine standard targets (brighter or darker?)
%    2.) Revise flower algorithm so that works with adjusted images
%    3.) Provide good estimates for threshold and cutoff given adjusted images.
%    4.) Revisit auto-cropping.
% ----Associated files
% gui_image_classify
% gui_image_lbox
%-----Current bugs
%    1.) Glitchy with listbox contents if classify_fig is open with load
%    all (just close and re-open).
%    2.) Can only have one classify gui open at one time.

% MEMORY ISSUE

% GUI_IMAGE_INTRO Application M-file for gui_image_intro.fig
%   GUI_IMAGE_INTRO, by itself, creates a new GUI_IMAGE_INTRO or raises the existing
%   singleton*.
%
%   H = GUI_IMAGE_INTRO returns the handle to a new GUI_IMAGE_INTRO or the handle to
%   the existing singleton*.
%
%   GUI_IMAGE_INTRO('CALLBACK',hObject,eventData,handles,...) calls the local
%   function named CALLBACK in GUI_IMAGE_INTRO.M with the given input arguments.
%
%   GUI_IMAGE_INTRO('Property','Value',...) creates a new GUI_IMAGE_INTRO or raises the
%   existing singleton*.  Starting from the left, property value pairs are
%   applied to the GUI before gui_image_intro_OpeningFunction gets called.  An
%   unrecognized property name or invalid value makes property application
%   stop.  All inputs are passed to gui_image_intro_OpeningFcn via varargin.
%
%   *See GUI Options - GUI allows only one instance to run (singleton).
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2000-2002 The MathWorks, Inc.

% Edit the above text to modify the response to help gui_image_intro

% Last Modified by GUIDE v2.5 08-Jul-2016 11:38:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',          mfilename, ...
                   'gui_Singleton',     gui_Singleton, ...
                   'gui_OpeningFcn',    @gui_image_intro_OpeningFcn, ...
                   'gui_OutputFcn',     @gui_image_intro_OutputFcn, ...
                   'gui_LayoutFcn',     [], ...
                   'gui_Callback',      []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    varargout{1:nargout} = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui_image_intro is made visible.
function gui_image_intro_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_image_intro (see VARARGIN)

% Choose default command line output for gui_image_intro
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Populate the listbox
update_listbox(handles)
set(handles.listbox1,'Value',[])

% UIWAIT makes gui_image_intro wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_image_intro_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function varargout = update_button_Callback(h, eventdata, handles, varargin)
% hObject    handle to update_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_listbox(handles)

function update_table(handles)
% hObject    handle to update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

% Updates the listbox to match the current workspace
vars = evalin('base','who');
varsIn = {};
for i = 1:length(vars) %Only show photos in listbox
    if strfind(vars{i},'DSCN') > 0
        varsIn = [varsIn vars{i}];
    end    
end
set(handles.uitable1,'String',varsIn)
set(handles.uitable1,'Value',[]) %this was added to address the bug.

function update_listbox(handles)
% hObject    handle to update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

% Updates the listbox to match the current workspace
vars = evalin('base','who');
varsIn = {};
for i = 1:length(vars) %Only show photos in listbox
    if strfind(vars{i},'DSCN') > 0
        varsIn = [varsIn vars{i}];
    end    
end
set(handles.listbox1,'String',varsIn)
set(handles.listbox1,'Value',[]) %this was added to address the bug.

function [var1] = get_var_names(handles)
% Returns the names of the two variables to plot
list_entries = get(handles.listbox1,'String');
index_selected = get(handles.listbox1,'Value');
var1 = list_entries{index_selected(1)};


%************************** LOAD FILES *********************************
% --- Executes on button press in loadfile.
function loadfile_Callback(hObject, eventdata, handles)
% hObject    handle to loadfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evalin('base','load tree')
[fnames,folder] = uigetfile('C:\IDEAS\Digital Images\*.JPG','Select Files to Load','MultiSelect','on');
if ischar(fnames)
    fnames = {fnames};
end
evalin('base','exist dirstruct');
chk = evalin('base','ans');
if chk == 0
    dirgui={};
else
    dirgui=evalin('base','dirstruct');
end
clear chk
evalin('base','clear ans')

if size(fnames,2) > 0 %If files have been selected 
    for i = 1:length(fnames) %Loop through files       
        varname = fnames(i);
        varname = char(strtok(varname,'.'));
        assignin('base',varname,importdata([folder,'\',char(fnames(i))]));
        finfo = imfinfo([folder,'\',char(fnames(i))]);
        len = length(folder);
        sta = folder(len-4:len-1);
        eval(['dirgui.',varname,'=cell(1,6)']);
        %eval(['dirgui.',varname,'={folder,finfo.FileModDate,sta}']);
        eval(['dirgui.',varname,'{1}=folder']);
        eval(['dirgui.',varname,'{2}=finfo.FileModDate']);
        eval(['dirgui.',varname,'{3}=sta']);
    end
end
clear i
clear varname
assignin('base','dirstruct',dirgui);
%Update Listbox with new variables
update_listbox(handles)

%************************** CROP *********************************
function varargout = crop_Callback(h, eventdata, handles, varargin)
% hObject    handle to crop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Ifname= get_var_names(handles);
I=evalin('base',Ifname);
figure
imshow(I)
title([Ifname,': Drag Rectangle Outline for Crop'],'Interpreter','none')
%User drags crop outline
[Icrop,rect] = imcrop; %Crop image
if isempty(Icrop) == 0  %If the user selected an area to crop   
    figure
    imshow(Icrop); %Display Image
    title([Ifname,'_crop',],'Interpreter','none')
    assignin('base',[Ifname,'_crop'],Icrop); %Assign value to variable in specified workspace
    assignin('base',[Ifname,'_crop_rect'],rect);
    dirgui=evalin('base','dirstruct');
    eval(['dirgui.',Ifname,'{4}=rect']);
    assignin('base','dirstruct',dirgui)
    
    %SAVE CROPPED FILE TO CROP FOLDER
    root_name=strtok(Ifname,'_');
    flder=evalin('base',['dirstruct.',root_name,'{1}']);
    cflder=[flder,'crop'];
    if isdir(cflder)== 0 %If the directory doesn't exist make it
        mkdir(cflder)
    end
    fname = [flder,'crop\',Ifname,'_crop.jpg'];
    imwrite(Icrop,fname) 
end
%Update Listbox with new variables
update_listbox(handles)

%************************** CLASSIFY SINGLE *********************************
% --- Executes on button press in classify_single_button.
function classify_single_button_Callback(hObject, eventdata, handles)
% hObject    handle to classify_single_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load tree
Ifname= get_var_names(handles);
I=evalin('base',Ifname);

%Apply Tree
f=1;
    for j=1:3
    RowS=I(:,:,j);
    all_rgb(:,j)=double(RowS(:));
    end
    ratioGR=all_rgb(:,2)./all_rgb(:,1);
    sumRGB=sum(all_rgb,2);
    x=[all_rgb,ratioGR,sumRGB];
    treeOut_x_0=treeval(t0,x);
    R=all_rgb(:,1);
    G=all_rgb(:,2);
    B=all_rgb(:,3);
    treeOut_x_0(B>G+40 & R>160)=4; %Blue Flowers
    treeOut_x_0(R./B>1.8 & G./B>1.8 & R+G>400)=5; %YELLOW FLOWERS
    hx(f,:)=hist(treeOut_x_0,1:5)/length(sumRGB); 
%Create Figure    
szImg=size(RowS);
m=szImg(1);
n=szImg(2);
yout=reshape(treeOut_x_0,m,n);
assignin('base','yout',yout)
figure
assignin('base','cfig',gcf)
subplot(1,2,1)
imagesc(yout)
axis image
cmap=[1 1 1; 0 0 0; 0 1 0; 0 0 1; 1 1 0]; %colormap: white, black, green, [Blue, Yellow]
set(gca,'CLim',[1 5])
colormap(cmap)
ytlabel={['NPV ',num2str(100*hx(f,1),2),'%'],...
    ['Shade ',num2str(100*hx(f,2),2),'%'],...
    ['GV ',num2str(100*hx(f,3),2),'%'],...
    ['Flr: Blu ',num2str(100*hx(f,4),2),'%'],...
    ['Flr: Yel ',num2str(100*hx(f,5),2),'%']};
colorbar(gca,[0.01195 0.7954 0.03765 0.18],...
  'Box','on',...
  'CLim',[1 5],'YLim',[1.25,4.75],...
  'YTick',[1.5 2.25 3 3.75 4.5],...
  'YTickLabel',ytlabel,...
  'Location','manual','FontWeight','Bold');
title([Ifname,' Classification (Tree1)'],'Interpreter','none')
subplot(1,2,2)
imagesc(I)
axis image
title([Ifname,' Original'],'Interpreter','none')
set(gcf,'Position',[1 1 810 500])

%************************** CLASSIFY BATCH******************************
function varargout = classify_button_Callback(h, eventdata, handles, varargin)
% hObject    handle to semilogy_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear all
load tree
fnames = evalin('base','fieldnames(dirstruct)'); %extracts the value of the variable in the MATLAB base workspace and captures the value in the local variable
fnames
evalin('base','clear DSCN*'); %*** CLEARS OUT ALL IMAGES IN WORKSPACE
q = 2;
for f = 1:length(fnames)
    clear RowS RowAll all_rgb ratioGR sumRGB x treeOut_x_0 yout R G B
    if strfind(fnames{i},'_crop') > 0
        %READ IMAGE FNAME
    fn = fnames{f};
    folder = evalin('base',['dirstruct.',fn,'{1}']);
    filename=[folder,fn,'.jpg'];
    evalin('base',[fn,'=imread(''',filename,''');']);
    evalin('base',['exist ',fnames{f}])
    chk=evalin('base','ans');
    if chk==1
    clear chk
    I = evalin('base',[fnames{f}]);
    Ifname=[fnames{f}];
    
    %Apply Tree
    for j=1:3
        RowS=I(:,:,j);
        all_rgb(:,j)=double(RowS(:));
    end
    ratioGR = all_rgb(:,2)./all_rgb(:,1);
    sumRGB = sum(all_rgb,2);
    %Troubleshooting
    %     assignin('base','all_rgb',all_rgb)
    %     assignin('base','ratioGR',ratioGR)
    %     assignin('base','sumRGB',sumRGB)
    
    x=[all_rgb,ratioGR,sumRGB];
    treeOut_x_0 = treeval(t0,x); %Warning: treefit will be removed in a future release. Use the predict method of an object returned by fitctree or fitrtree instead. 
    %treeOut_x_0 = fitctree(t0,x);
    R=all_rgb(:,1);
    G=all_rgb(:,2);
    B=all_rgb(:,3);
    treeOut_x_0(B>G+40 & R>160)=4; %Blue Flowers
    treeOut_x_0(R./B>1.8 & G./B>1.8 & R+G>400)=5; %YELLOW FLOWERS
    hx(f,:)=hist(treeOut_x_0,1:5)/length(sumRGB); 
    %Create Figure    
    szImg=size(RowS);
    m=szImg(1);
    n=szImg(2);
    yout = reshape(treeOut_x_0,m,n);

    assignin('base','yout',yout)%Assigning Variables to Workspace
    figure
    assignin('base','cfig',gcf) %Assign value to variable in specified workspace
    
    %Display Classification Results
    subplot(1,2,1)
    imagesc(yout)%Display image with scaled colors
    axis image
    cmap = [1 1 1; 0 0 0; 0 1 0; 0 0 1; 1 1 0]; %colormap: white, black, green, [Blue, Yellow]
    set(gca,'CLim',[1 5])
    colormap(cmap)
    ytlabel={['NPV ',num2str(100*hx(f,1),2),'%'],...
        ['Shade ',num2str(100*hx(f,2),2),'%'],...
        ['GV ',num2str(100*hx(f,3),2),'%'],...
        ['Flr: Blu ',num2str(100*hx(f,4),2),'%'],...
        ['Flr: Yel ',num2str(100*hx(f,5),2),'%']};
    colorbar(gca,... %[0.01195 0.7954 0.03765 0.18],
        'Box','on',...
        'YLim',[1.25,4.75],... %'CLim',[1 5],
        'YTick',[1.5 2.25 3 3.75 4.5],...
        'YTickLabel',ytlabel,...
        'Location','manual','FontWeight','Bold');
    title([Ifname,' Classification (Tree1)'],'Interpreter','none')
    
    subplot(1,2,2)
    imagesc(I)
    axis image
    title([Ifname,' Original'],'Interpreter','none')
    set(gcf,'Position',[1 1 810 500])
    
    %Save Image to File
    root_name = Ifname;
    flder = evalin('base',['dirstruct.',root_name,'{1}']);
    cflder=[flder,'class'];
    if isdir(cflder)==0 
        mkdir(cflder)
    end
    fname=[flder,'class\',Ifname,'_class.jpg'];
    evalin('base',['saveas(cfig,''',fname,''')'])
    
    %Save Data to dirstruct 
    dirgui=evalin('base','dirstruct');
    eval(['dirgui.',root_name,'{5}=hx(f,:);']);
    eval(['dirgui.',root_name,'{6}=fname;']);
    assignin('base','dirstruct',dirgui);
    pfiles(q)={Ifname};
    q=q+1;
    
    %If No File 
    else
        disp([fnames{f},'_crop does not exist'])
    end
    close all
    evalin('base','clear DSCN*'); %*** CLEARS OUT ALL IMAGES IN WORKSPACE
    end     
end
assignin('base','pfi',pfiles)
pfiles(1)={'Done processing the cropped files:'};
msgbox(pfiles)

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = ispc;
if usewhitebg
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in loadfile.
function loadfiles_Callback(hObject, eventdata, handles)
% hObject    handle to loadfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
eval('gui_image_lbox')


% --- Executes on button press in close_fig.
function close_fig_Callback(hObject, eventdata, handles)
% hObject    handle to close_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all





% --- Executes on button press in create_csv.
function create_csv_Callback(hObject, eventdata, handles)
% hObject    handle to create_csv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fileout,path] = uiputfile(['ccd_stats_',datestr(now,'ddmmmyy'),'.csv'],'Save file name');

dirgui=evalin('base','dirstruct');
fn=fieldnames(dirgui);
fid=fopen([path,char(fileout)],'w');
fprintf(fid,'Filepath,File,Date,NPV,Shade,GV,Flower Blue, Flower Yellow, Class Img. Name, Link \n');
for i = 1:length(fn)
    out=eval(['dirgui.',fn{i}]);
    fprintf(fid,'%s,%s,%s,%s,',char(out{1}),char(fn{i}),char(out{2}));
    %fprintf(fid,'%f,%f,%f,%f,',out{4}); %Crop Rect. Values (4 vals, cell 4)
    fprintf(fid,'%f ,%f,%f,%f,%f,',out{5}); %Classif. Values (5 vals, cell 5)
    fprintf(fid,'%s,',char(out{6})); %Filename for Output Figure
    fprintf(fid,'%s, \n',['=hyperlink("',char(out{6}),'")']); %Filename for Output Figure
end
fclose(fid);
disp('done!')



% --- Executes on button press in imtool_button.
function imtool_button_Callback(hObject, eventdata, handles)
% hObject    handle to imtool_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Ifname= get_var_names(handles);
I=evalin('base',Ifname);
imtool(I);



% --- Executes on button press in clear_button.
function clear_button_Callback(hObject, eventdata, handles)
% hObject    handle to clear_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evalin('base','clear all')
%Update Listbox with new variables
update_listbox(handles)


% --- Executes on button press in save_work.
function save_work_Callback(hObject, eventdata, handles)
% hObject    handle to save_work (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileout,path] = uiputfile(['ccd_wkspace_',datestr(now,'ddmmmyy'),'.mat'],'Save file name');



% --- Executes on button press in targclassbutton.
function targclassbutton_Callback(hObject, eventdata, handles)
% hObject    handle to targclassbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Ifname= get_var_names(handles);
I=evalin('base',Ifname);
imtool_eb(I)
isize=size(I);
gui_target_classify(Ifname)
assignin('base','Ifname',Ifname)








% --------------------------------------------------------------------
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (hObject == handles.clear_day)
3
else
    5
end


% --- Executes during object creation, after setting all properties.
function uipanel2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in radiobutton7.
function radiobutton7_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton7


% --- Executes during object creation, after setting all properties.
function radiobutton7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load tree
treedisp(t0,'name',{'r','g','b','g/r','sumRGB'});

% --- Executes on button press in clear_imgs.
function clear_imgs_Callback(hObject, eventdata, handles)
% hObject    handle to clear_imgs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

evalin('base','clear DSC*')






% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
