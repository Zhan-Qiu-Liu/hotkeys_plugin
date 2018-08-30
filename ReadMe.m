function ReadMe(varargin)
% hObject    handle to ReadMe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% generate Report for Hotkeys
	%
	%
	% USAGE:
	%   self.ReadMe()
	%
	% OUTPUTS;
	%           
	%
	% Last Modified: 11:52 AM Monday, November 23, 2015
	% Modified By: Zhanqiu Liu (lafeir.lew@gmail.com)

	%--- Hotkeys Entries ---%
	report={'<<<Known Bugs>>>', ...
			'1.Error in plugins.PluginMenu/checkAvailability', ...
			'Solution:', ...
			'', ...
			'', ...
			'', ...
			'<<<Known Issues>>>', ...
			'', ...
			'',};

	msgbox(report,'Known Bugs and Issues');

end
