function varargout = gui_image_intro(varargin)
% ---To Do:
%    1.) Need to refine standard targets (brighter or darker?)
%    2.) Revise flower algorithm so that works with adjusted images
%    3.) Provide good estimates for threshold and cutoff given adjusted
%    images.
%    4.) Revisit auto-cropping.
% ----Associated files
% gui_image_classify
% gui_image_lbox
%-----Current bugs
%    1.) Glitchy with listbox contents if classify_fig is open with load
%    all (just close and re-open).
%    2.) Can only have one classify gui open at one time.

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

% Last Modified by GUIDE v2.5 22-Apr-2008 22:15:01

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

function update_listbox(handles)
% hObject    handle to update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

% Updates the listbox to match the current workspace
vars = evalin('base','who');
set(handles.listbox1,'String',vars)

function [var1] = get_var_names(handles)
% Returns the names of the two variables to plot
list_entries = get(handles.listbox1,'String');
index_selected = get(handles.listbox1,'Value');
var1 = list_entries{index_selected(1)};

%************************** STANDARDIZE *********************************
function varargout = standardize_Callback(h, eventdata, handles, varargin)
% hObject    handle to standardize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Load Original Image
figure
Ifname= get_var_names(handles);
I=evalin('base',Ifname);
imshow(I)
title({[Ifname,': Select 6 targets from Standards block (going from '...
    'Black to White, click once on each square for a total of 6 targets, '...
    'hit Enter when done)']})
%Six pixels selected (black to white, 6 pts, one for each block
n=impixel;
assignin('base',[Ifname,'_n'],n);
title(Ifname)
%Std colors to scale to *** Change this when have final standards to use**
%Standards from DSCN9492 (COP, 5April08)
%stdcolors=[123 122 136;156 142 165;175 170 190;194 185 204;234 228 242;255 255 255]
%Standards from DSCN9440,9441,9442,9445
if get(handles.cloudy_radio,'Value')==1
    %cloudy
stdcolors=[130 126 152;146 142 167;159 155 180;171 167 192;211 207 232;242 241 246];
else
    %clear
stdcolors=[106 104 115;143 141 155;167 165 179;185 175 192;218 216 230;251 251 251];
end


stdcolors

%Regress to find beta coefficients for scaling
figure
set(gcf,'Position',[1,1,700,200])
colortext={'Red','Green','Blue'};
ctxt={'r.','g.','b.'};
for i=1:3
    %regression
    [stats]=regstats(stdcolors(:,i),n(:,i)); %regstats(y,x,..), plot(x,y)
    beta{i}=[stats.beta;stats.rsquare];
    Iadj(:,:,i)=I(:,:,i)*beta{i}(2)+beta{i}(1);
    %plot to show regression
    subplot(1,3,i)
    plot(n(:,i),stdcolors(:,i),ctxt{i})
    ylabel('Ref std')
    xlabel('Img std')
    title([Ifname,' ',colortext{i}])
    h=refline(beta{i}(2),beta{i}(1))
    set(h,'Color','k')
    axis([0 256 0 256])
    text(50,180,{['intercept=',num2str(beta{i}(1),3)],...
        ['slope=',num2str(beta{i}(2),3)],...
        ['r2=',num2str(beta{i}(3),3)]})
end
%Show Adjusted Image
figure
imshow(Iadj)
title([Ifname,'_adj'],'Interpreter','none')
%Write Output
assignin('base',[Ifname,'_adj'],Iadj);
assignin('base',[Ifname,'_beta'],beta);
%Update Listbox with new variables
update_listbox(handles)

%************************** AUTO CROP *********************************
% --- Executes on button press in autocrop_button.
function autocrop_button_Callback(hObject, eventdata, handles)
% hObject    handle to autocrop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%SET CROP RECTANGLE
%rect=[xmin ymin width height]
%rect=[500,170,1500,1560];

%GET Image and Image Name
Ifname= get_var_names(handles);
I=evalin('base',Ifname);
rect=evalin('base',[Ifname,'_adj_crop_rect']);
%Create Cropped Image and Display
crop_Ifname=[Ifname,'_crop'];
Icrop=imcrop(I,rect);
%Write to Base
assignin('base',[crop_Ifname],Icrop);
figure
imshow(Icrop)
title([crop_Ifname],'Interpreter','none')
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
[Icrop,rect] = imcrop;
figure
imshow(Icrop);
title([Ifname,'_crop',],'Interpreter','none')
assignin('base',[Ifname,'_crop'],Icrop);
assignin('base',[Ifname,'_crop_rect'],rect);
%Update Listbox with new variables
update_listbox(handles)

%************************** CLASSIFY *********************************
function varargout = classify_button_Callback(h, eventdata, handles, varargin)
% hObject    handle to semilogy_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Ifname= get_var_names(handles);
I=evalin('base',Ifname);
assignin('base',['I'],I);
assignin('base',['Ifname'],Ifname);
%Utilizes gui_image_classify**
eval('gui_image_classify')



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

[fileout,path] = uiputfile(['ccd_stats_',datestr(now,'ddmmmyy'),'.csv'],'Save file name')
out=evalin('base','out');
fn=fieldnames(out);
fid=fopen([path,char(fileout)],'w');
fprintf(fid,'Filename,Original File,Meta Text,NPV,Shade,GV,Flower Blue, Flower Yellow, Sum Threshold,G/R Ratio\n');
for i = 1:length(fn)
    fprintf(fid,'%s,%s,',char(fn{i}),strtok(fn{i},'_'));
    stats=evalin('base',['out.',fn{i}]);
    fprintf(fid,'%s,',char(stats{2}));
    fprintf(fid,'%f ,%f,%f,%f,%f,%f,%f \n',stats{1});
end
fclose(fid)


% --- Executes on button press in load_all.
function load_all_Callback(hObject, eventdata, handles)
% hObject    handle to load_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

folder=uigetdir;
fnames=dir([folder,'\*.JPG']);


evalin('base','exist dirstruct');
chk=evalin('base','ans');
if chk==0
dirgui={}
else
dirgui=evalin('base','dirstruct')
end
clear chk

if isempty(fnames)
    errordlg('No JPG files in folder')
else
    for i=1:length(fnames)
        varname=fnames(i).name;
        varname=strtok(varname,'.')
        assignin('base',varname,importdata([folder,'\',fnames(i).name]))
        eval(['dirgui.',varname,'=folder']);
    end
end
clear i
clear varname
assignin('base','dirstruct',dirgui)
%Update Listbox with new variables
vars = evalin('base','who');
set(handles.listbox1,'String',vars)

% --- Executes during object creation, after setting all properties.
function load_all_CreateFcn(hObject, eventdata, handles)
% hObject    handle to load_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in loadfile.
function loadfile_Callback(hObject, eventdata, handles)
% hObject    handle to loadfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fnames,folder]=uigetfile('*.JPG','Select Files to Load','MultiSelect','on')
if ischar(fnames)
    fnames={fnames};
end

evalin('base','exist dirstruct')
chk=evalin('base','ans')
if chk==0
dirgui={}
else
dirgui=evalin('base','dirstruct')
end
clear chk

for i=1:length(fnames)
        varname=fnames(i);
        varname=char(strtok(varname,'.'));
        assignin('base',varname,importdata([folder,'\',char(fnames(i))]));
        eval(['dirgui.',varname,'=folder']);
end
clear i
clear varname
assignin('base','dirstruct',dirgui)
%Update Listbox with new variables
update_listbox(handles)

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
[fileout,path] = uiputfile(['ccd_wkspace_',datestr(now,'ddmmmyy'),'.mat'],'Save file name')



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



% --- Executes on button press in clear_radio.
function clear_radio_Callback(hObject, eventdata, handles)
% hObject    handle to clear_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of clear_radio


% --- Executes on button press in cloudy_radio.
function cloudy_radio_Callback(hObject, eventdata, handles)
% hObject    handle to cloudy_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cloudy_radio




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


