classdef ViewerStatus < hgsetget
% Last Modified: 11:52 AM Monday, November 23, 2015
% Modified By: Zhanqiu Liu (lafeir.lew@gmail.com)

    methods

		function self = ViewerStatus(handles,flag)
		%% properties of DENSEviewer.m (SetAccess='private',GetAccess='public')
		%% properties of DENSEdata.m (SetAccess='private',GetAccess='public')
            %
            % INPUTS:
            %   self:   Object,  Instance of the TestPlugin object
            %   handles:    struct, guidata structure from the DENSEanalysis
            %               GUI. This provides access to all data and controls 
            %               in the GUI.
			%{ 
			if handles.hsidebar.ActiveTab == 2
				options = struct([]);
				% handles = handles@DataViewer(options,varargin{:});
				handles = DENSEviewerFcn(handles);
				handles.redrawenable = true;
				redraw(handles);
				handles.exportaxes = true;
			end
			 %}

			%{ 
			%% function resetdisp(handles):
			% stop the playbar
			handles.hlisten_playbar.Enabled = false;  
			handles.hplaybar.Max = 0;    
			% disable export
			handles.isAllowExportImage = false;
			handles.isAllowExportVideo = false;   
			 %}
			
			% gather DENSE display parameters
			N2 = numel(handles.hdata.dns);
			
			switch lower(flag)
			case 'load'
			%% handles.hdense.displaydata is read-only:
				for k = 1:N2
					
					% DENSE information
					sidx  = [handles.hdata.dns(k).MagIndex;
							 handles.hdata.dns(k).PhaIndex];
					sidx0 = sidx(find(~isnan(sidx(1,:)),1,'first'));
					% viewport = seqdata(sidx0).Viewport;
					viewport = handles.hdata.seq(sidx0).Viewport;
					contrast = handles.hdata.seq(sidx0).Contrast;

					%% save to fields of object

					handles.hdense.displaydata(k).CurrentCLim   = reshape(repmat([contrast,[0 1]],[1 3]),[1 2 6]);
					% handles.hdense.displaydata(k).CurrentCLim   = repmat([0 1],[1 1 6]);
					handles.hdense.displaydata(k).CurrentXYLim  = [viewport(1),viewport(1) + viewport(3),viewport(2),viewport(2) + viewport(4)] + 0.5;
					% handles.hdense.displaydata(k).CurrentXYLim  = xylim;
				end
			case 'save'
			%% handles.hdata.seq or handles.hdata.seq(name in upper level) is read-only:
				% didx = handles.dnsidx;
				% lim = handles.hdense.displaydata(didx).CurrentXYLim;
				
				N1 = numel(handles.hdense.displaydata);
				if ~isequal(N1,N2)
					error(sprintf('%s:invalidInput',mfilename),'%s',...
						'"numel(handles.hdense.displaydata)=',sprintf('%d',N1),'" is NOT equal to "numel(handles.hdata.dns)=',sprintf('%d',N2),'"')		
					return;
				end
				
				%% Update Zoom & Contrast level
				lim = (reshape([handles.hdense.displaydata(:).CurrentXYLim],4,[]))';
				for k = 1 : N1
					contrast(k,:) = handles.hdense.displaydata(k).CurrentCLim(:,:,1);
				end
				
				% handles.hdata.seq(midx(1)).Viewport = [lim(1) lim(3) lim(2) lim(4)]-0.5;
				%% Use method instead
				viewport = [lim(:,1)-0.5 lim(:,3)-0.5 lim(:,2)-lim(:,1) lim(:,4)-lim(:,3)];
				FLAG = 'DENSE';
				
				switch upper(FLAG)
					case 'DENSE'
						for k = 1 : numel(handles.dns)
							idx = handles.dns(k).MagIndex(1);
							handles.hdata.seq(idx).Viewport = viewport(k,:);
							handles.hdata.seq(idx).Contrast = contrast(k,:);
						end
					case 'DICOM'	
						for k = 1 : numel(handles.hdata.seq)
							handles.hdata.seq(k).Viewport = viewport(k,:);		
							handles.hdata.seq(k).Contrast = contrast(k,:);
						end
					otherwise
						error(sprintf('%s:invalidInput',mfilename),'%s',...
							'Unsupported Viewer: "',sprintf('%s',FLAG),'"')		
				end
			end
		end
		
    end

end
