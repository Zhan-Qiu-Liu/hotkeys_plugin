classdef HotkeysPlugin < plugins.DENSEanalysisPlugin
    % HotkeysPlugin - A DENSEanalysis plugin
    %
    %   A plugin for adding Hotkeys
    %
	% This package was created using the windowkeypress function written by Dr. Jonathan Suever as a template.
	% 
	% Modified By: Zhanqiu Liu (lafeir.lew@gmail.com)
	% Last Modified: 10:20 July 12, 2017
    properties
        Handles
		aside = [];
    end
	
    methods

        function self = HotkeysPlugin(varargin)
            import plugins.hotkeys_plugin.*
			% load plugin config: plugin.json file
            self@plugins.DENSEanalysisPlugin(varargin{:});
			
            handles = guidata(self.hfig(1));
			% viewer = get(handles.hsidebar.CurrentPanel, 'UserData');
		
			%DENSE viewer is default: useless due to the refresh after loading
			% handles.LastTab = 2;

			%% Callback for all window keypress events
			% BEHAVIOR@VIEWER---------------------------------------------
			set(handles.hfig, 'WindowKeyPressFcn', @windowkeypressREPL)

			%% Remap for all menu click events
            % set(findobj(handles.hfig, 'tag', 'menu_runanalysis'),'Accelerator','A');
            % Now remap some of the callbacks to our desired functions
			% NOT Working: load without selection GUI
            % set(findobj(handles.hfig, 'tag', 'menu_open'), 'Callback', @(s,e)openFcnREPL(handles));
            % set(findobj(handles.hfig, 'tag', 'menu_save'), 'Callback', @(s,e)saveFcnREPL(handles,false));
            % set(findobj(handles.hfig, 'tag', 'menu_saveas'), 'Label', 'Save Workspace As (Ctrl+Shift+S)');
            % set(findobj(handles.hfig, 'tag', 'menu_saveas'), 'Callback', @(s,e)saveFcnREPL(handles,true));
			
			%% Add toolbar items
			cdata = load(fullfile(self.InstallDir,'icons.mat'),'-mat');
			htoolbar = get(findall(handles.hfig, 'tag', 'tool_new'), 'Parent');
			% button = get(findall(handles.hfig, 'type', 'uitoolbar'),'tag');
			% htoolbar = get(get(findall(handles.hfig, 'type', 'uitoolbar'),'tag', 'tool_new'), 'Parent');
			
			self.Handles.tool_DataCursor = uitoolfactory(htoolbar,'Exploration.DataCursor');
			set(self.Handles.tool_DataCursor,'TooltipString','Data Cursor(Alt+D)');
			% self.Handles.tool_Brush = uitoolfactory(htoolbar,'Exploration.Brushing');
			% set(self.Handles.tool_Brush,'Separator','on','TooltipString','Brushing(Alt+B)');
			self.Handles.tool_reload = uipushtool(...
			'Parent',htoolbar,...
			'Separator',        'on', ...
			'ClickedCallback',@(s,e)reloadFcn(self),...
			'CData',cdata.tool_reload,...
			'TooltipString','Reload Workspace(Ctrl+R)',...
			'Tag','tool_reload');
			%{ 
			% plugins.DENSEanalysisPlugin is a valid base class, not DENSEanalysis:
			uipushtool(...
			'Parent',htoolbar,...
			'ClickedCallback',saveFcn@DENSEanalysis(handles,true),...
			'CData',cdata.tool_saveas,...
			'TooltipString','Save Workspace As(Ctrl+Shift+S)',...
			'BusyAction','cancel',...
			'Interruptible','off',...
			'Tag','tool_saveas');
			% NO update passed to roitool: obj.roiidx is empty forever
			uipushtool(...
			'Parent',htoolbar,...
			'Separator',        'on', ...
			'ClickedCallback',@(s,e)viewer.hroi.cut(),...
			'CData',cdata.tool_roi_cut,...
			'TooltipString','Cut ROI(Ctrl+X)',...
			'Tag','tool_roi_cut');
			uipushtool(...
			'Parent',htoolbar,...
			'ClickedCallback',@(s,e)copy(viewer),...
			'CData',cdata.tool_roi_copy,...
			'TooltipString','Copy ROI(Ctrl+C)',...
			'Tag','tool_roi_copy');
			uipushtool(...
			'Parent',htoolbar,...
			'ClickedCallback',@(s,e)viewer.hroi.paste(),...
			'CData',cdata.tool_roi_paste,...
			'TooltipString','Paste ROI(Ctrl+V)',...
			'Tag','tool_roi_paste');
			 %}
			 
			%% Add menu items
			% load without selection GUI
			Parent = findall(handles.hfig, 'tag', 'menu_file');
			self.Handles.menu_reload = uimenu('Parent', Parent, 'Label', 'Reload', 'Callback', @(s,e)reloadFcn(self),'Accelerator','R');
			% link some menu enable to tool enable
			setappdata(self.Handles.tool_reload,'linkMenuToolEnable',linkprop([self.Handles.tool_reload,self.Handles.menu_reload],'Enable'))
			
			% parent = get(findall(handles.hfig, 'tag', 'menu_file'), 'Parent');
			Parent = get(Parent, 'Parent');
			self.Handles.menu_append = uimenu('Parent', Parent, 'Label', 'Plugin_Hotkeys');
			uimenu('Parent', self.Handles.menu_append, 'Label', 'Important Dataset Info.', 'Callback', @(s,e)DatasetInfo(handles),'Accelerator','I');
			% uimenu('Parent', self.Handles.menu_append, 'Label', 'Auto-build:SA RVendo(LVendo+epi required)', 'Callback', @(s,e)XformDNS_LV2BV(true,fullfile(get(handles.config,'locations.matpath',userdir()),get(handles.config, 'locations.matfile',userdir())),self),'Accelerator','B');%'DENSEanalysis workspace v0.4->v0.5'
			% uimenu('Parent', self.Handles.menu_append, 'Label', 'Auto-build:SA Epi(BV required)', 'Callback', @(s,e)XformDNS_BV2Epi(true,fullfile(get(handles.config,'locations.matpath',userdir()),get(handles.config, 'locations.matfile',userdir())),self),'Accelerator','E');
			%{ 
			% NO PERMISSION for DENSEviewer.m and DENSEdata.m:
			uimenu('Parent', self.Handles.menu_append, 'Label', 'Load Contrast Status and Zoom Status', 'Callback', @(s,e)ViewerStatus(handles,'load'));
			uimenu('Parent', self.Handles.menu_append, 'Label', 'Save Contrast Status and Zoom Status', 'Callback', @(s,e)ViewerStatus(handles,'save'));
			 %}
			uimenu('Parent', self.Handles.menu_append, 'Label', 'Summary of Hotkeys', 'Callback', @HotkeysSummary,'Accelerator','H');
			% uimenu('Parent', self.Handles.menu_append, 'Label', 'Known Bugs and Issues', 'Callback', @ReadMe);
			

			%% Bind more keyboard events
			accelerators = struct(...
				'menu_exportmat',        'M', ...
				'menu_exportexcel',       'X', ...
				'menu_exportroi',        'R', ...
				'menu_test', 'T');
			func = @(x,y)set(findobj(handles.hfig, 'tag', x), 'Accelerator', y);
			cellfun(func, fieldnames(accelerators), struct2cell(accelerators));
			%{ 
			% Maximize the figure
			frame_h = get(handle(handles.hfig),'JavaFrame');
			set(frame_h,'Maximized',1);
			 %}
        end

        function h = uimenu(varargin)
		%% Make sure PluginMenu.m DONNOT create a menu entry for this plugin:
            % Enable checkAvailability:
			% h = gobjects(1,1);
            % Disable checkAvailability:
            h = [];		
        end

        function delete(self)
		
            % Make sure all UI components are removed
			cellfun(@(x)(delete([self.Handles.(x)])),fieldnames(self.Handles),'UniformOutput',false)

			% Call superclass destructor
			delete@plugins.DENSEanalysisPlugin(self);
        end

		function validate(varargin)
            % validate - Check if the plugin can run.
            %
            %   Performs validation to ensure that the state of the program
            %   is correct to be able to run the plugin.
            %
            % USAGE:
            %   HotkeysPlugin.validate(data)
            %
            % INPUTS:
            %   data:   Object, DENSEdata object containing all underlying
            %           data from the DENSEanalysis program.
        end

        function run(varargin)
		%% CANNOT DELETE: otherwise it will become a abstract class
            % run - Method executed when user selects the plugin
            %
            % USAGE:
            %   HotkeysPlugin.run(data)
            %
            % INPUTS:
            %   data:   Object, DENSEdata object containing all underlying
            %           data from the DENSEanalysis program.
        end

		function reloadFcn(self)
            handles = guidata(self.hfig(1));
			if isempty(handles.hdata)
				return
			end
			
			% proper startpath
			% startpath = get(handles.config, 'locations.matfile', userdir());
			startpath = fullfile(get(handles.config, 'locations.matpath', userdir()),get(handles.config, 'locations.matfile', userdir()));

			% try to load new data
			try
				[uipath,uifile] = load(handles.hdata,'dns',startpath);
			catch ERR
				uipath = [];
				errstr = ERR.message;
				h = errordlg(errstr,'','modal');
				ERR.getReport()
				waitfor(h);
			end
			if isempty(uipath), return; end
			%{ 
			% save path to figure
			set(handles.config, 'locations.matpath', uipath)
			set(handles.config, 'locations.matfile', uifile)
			
			[~,f,~] = fileparts(uifile);
			% set(handles.config, 'locations.dnsname', f)

			guidata(handles.hfig,handles);

			% figure name
			set(handles.hfig,'Name',['DENSEanalysis: ' f]);

			% update figure
			resetFcn(handles.hfig);
			 %}
		end
    end
end

function windowkeypressREPL(src,evnt)
% This package was created using the windowkeypress function (https://github.com/denseanalysis/denseanalysis/blob/master/DENSEanalysis.m) written by Dr. Jonathan Suever as a template.
% Copyright (c) 2016 DENSEanalysis Contributors
% Last Modified: 8:37 PM Friday, November 20, 2015
% Modified By: Zhanqiu Liu (lafeir.lew@gmail.com)
	if isempty(evnt.Modifier)
		key = evnt.Key;
	else
		key = [evnt.Modifier{1},evnt.Key];
		% modifiers = sort(evnt.Modifier);
		% key = strcat(sprintf('%s-', modifiers{:}), evnt.Key);
	end

	handles = guidata(src);

	% Returns a handle to the current DataViewer
	viewer = get(handles.hsidebar.CurrentPanel, 'UserData');
	if ~isa(viewer, 'DataViewer')
		return;
	end
	playbar = viewer.hplaybar;

	switch key
	% menu
		% 'command' for Macintosh computers
		case {'controlz', 'commandz'}
			if isa(viewer, 'DENSEviewer') || isa(viewer, 'DICOMviewer')
				cLine = viewer.hroi.cLine;
				if cLine.UndoEnable
					cLine.undo();
				end
			end
		case {'controlc', 'commandc'}
			if isa(viewer, 'DENSEviewer') || isa(viewer, 'DICOMviewer')
				viewer.hroi.copy();
			end
		case {'controlx', 'commandx'}
			if isa(viewer, 'DENSEviewer') || isa(viewer, 'DICOMviewer')
				viewer.hroi.cut();
			end
		case {'controlv', 'commandv'}
			if isa(viewer, 'DENSEviewer') || isa(viewer, 'DICOMviewer')
				viewer.hroi.paste();
			end
		% DENSEanalysis is NOT a class!
		% case {'control-shift-s','command-shift-s'}
			% saveFcn(handles,true);
	% toolbar
		case 'e'
			if strcmpi(get(handles.tool_roi, 'state'), 'on')
				set(handles.tool_roi, 'State', 'off')
			else
				set(handles.tool_roi, 'State', 'on')
			end
			cb = get(handles.tool_roi, 'ClickedCallback');
			feval(cb, handles.tool_roi, []);
		case 'equal'
			ax = get(handles.hfig, 'CurrentAxes');
			zoom(ax, 2);
		case 'hyphen'
			ax = get(handles.hfig, 'CurrentAxes');
			zoom(ax, 0.5);
		case 'altp'
		% Toggle for panning images
			pan(handles.hfig);
			hmanager = uigetmodemanager(handles.hfig);
			set(hmanager.WindowListenerHandles,'enable','off');
			set(handles.hfig,'WindowKeyReleaseFcn',@(s,e)pan(handles.hfig));
		case 'altd'
		% Toggle for data cursor
			datacursormode(handles.hfig);
			hmanager = uigetmodemanager(handles.hfig);
			set(hmanager.WindowListenerHandles,'enable','off');
			set(handles.hfig,'WindowKeyReleaseFcn',@(s,e)pan(handles.hfig));						
		case 'altc'
		% Toggle for contrast enhancement controls
			set(handles.hcontrast,'Enable','on');
			cb = @(s,e)set(handles.hcontrast,'Enable','off');
			hmanager = uigetmodemanager(handles.hfig);
			set(hmanager.WindowListenerHandles,'enable','off');
			set(handles.hfig,'WindowKeyReleaseFcn',cb);	
		case 'altr'
		% Toggle for 3D rotation tool
			rotate3d(handles.hfig);
			hmanager = uigetmodemanager(handles.hfig);
			set(hmanager.WindowListenerHandles,'enable','off');
			set(handles.hfig,'WindowKeyReleaseFcn',@(s,e)rotate3d(handles.hfig));
		%{ 
		case 'altb'
		% Toggle for brush tool
			brush(handles.hfig);
			hmanager = uigetmodemanager(handles.hfig);
			set(hmanager.WindowListenerHandles,'enable','off');
			set(handles.hfig,'WindowKeyReleaseFcn',@(s,e)brush(handles.hfig));
		 %}
	%Viewer
		case {'d', 'rightarrow'}%'n', 
			if ~isempty(playbar.Value) && ~playbar.IsPlaying
				playbar.Value = mod(playbar.Value, playbar.Max) + 1;
			end
		case {'a', 'leftarrow'}%'b', 
			if ~isempty(playbar.Value) && ~playbar.IsPlaying
				playbar.Value = mod((playbar.Value - 2), playbar.Max) + 1;
			end
		case {'w', 'uparrow'}
		% Display upper active Tab
			handles.hsidebar.ActiveTab = mod((handles.hsidebar.ActiveTab - 2),handles.hsidebar.NumberOfTabs) + 1;
		case {'s', 'downarrow'}
		% Display lower active Tab
			handles.hsidebar.ActiveTab = mod(handles.hsidebar.ActiveTab,handles.hsidebar.NumberOfTabs) + 1;
		case {'numpad1','numpad2','numpad3','numpad4','numpad5','numpad6','numpad7','numpad8','numpad9','numpad0'}
		% Change the active Slice
			if handles.hsidebar.ActiveTab == 2
				h = handles.hdense.hdns_menu;
				%{ 
				switch handles.hsidebar.ActiveTab
					case 1,h = handles.hdicom.hseq_menu;
					case 2,h = handles.hdense.hdns_menu;				
					% case 3,h = handles.hanalysis.hslice_menu;				
				end
				 %}
				nDns = numel(get(h,'string'));
				sel = str2double(key(end));
				if isequal(sel,0),sel = double(10);end
				if sel <= nDns
					set(h,'value',sel);
					feval(get(h,'callback'));
				end
				
			end
		case {'1','2','3','4','5','6','7','8','9'}%,'0'
		% Change the active ROI
			if handles.hsidebar.ActiveTab == 2
				h = handles.hdense.hroi_menu;
				%{ 
				switch handles.hsidebar.ActiveTab
					case 1,h = handles.hdicom.hroi_menu;
					case 2,h = handles.hdense.hroi_menu;				
					% case 3,h = handles.hanalysis.hslice_menu;				
				end
				 %}
				nRoi = numel(get(h,'string')) - 1;
				sel = str2double(key);
				if sel <= nRoi
					set(h,'value',sel + 1);
					feval(get(h,'callback'));
				end					
			end
		case 'backquote'
		% Deactivate ROI
			if handles.hsidebar.ActiveTab == 2
				h = handles.hdense.hroi_menu;
				%{ 
				switch handles.hsidebar.ActiveTab
					case 1,h = handles.hdicom.hroi_menu;
					case 2,h = handles.hdense.hroi_menu;				
					% case 3,h = handles.hanalysis.hslice_menu;				
				end
				 %}
				set(h,'value',1);
				feval(get(h,'callback'));
			end
		case 'tab'
		% Change the active Tab
			switch handles.hsidebar.ActiveTab
				case 1,handles.hsidebar.ActiveTab = 2;
				case 2,handles.hsidebar.ActiveTab = 1;				
				case 3,handles.hsidebar.ActiveTab = 2;				
				case 4,handles.hsidebar.ActiveTab = 2;				
			end
		case 'space'
		% Toggle movie playing
			if isempty(playbar.Value)
				return
			end

			if playbar.IsPlaying
				playbar.stop()
			else
				playbar.play()
			end
	end
end

