function make_latex
% make_plot_latex_default(X1,Y1,xlab,ylab,axlims,lege_nm,varargin)
% take exsisting plot and convert to LaTeX stype

%  X1:      plot x (:,n) for n columns of data
%  Y1:      plot y (:,n) for n columns of data
%  axlims:  1x4 vector of [xmin xmax ymin ymax]
%  xlab:    xlabel name (str)
%  ylab:    ylabel name (str)
%  lege_nm: variable names to be printed in legend (list --> {...})
%  plot_colour: nx3 vector in RGB (see X1 above for definition of n)
%  fontszs: 1x3 vector of font sizes, in order: xy label, legend, axis
%  sloc:    save location (str)
%  ploc:    alternative location to save (str)
%  log_option: 0 -> normal plot     }
%              1 -> semilogx        }  log_option updates plot_name with a
%              2 -> semilogy        }  suffix (eg. [plot_name,'_xlog')
%              3 -> loglog          }        

% -------------------------------------------------------------------------
% DEFINE DEFAULT VALUES
% -------------------------------------------------------------------------

fontsz_xy = 20;
fontsz_legend = 14;
fontsz_ax = 16;

%markers = {'o';'^';'square';'v';'x';'+';'*'};

%plot_colours = [0 0 0];

% Make X and Y data column vectors
% if ~isequal(size(X1),size(Y1))
%     return
% end
% if size(Y1,2)>size(Y1,1)
%      X1=X1';
%      Y1=Y1';
% end

% may need to rescale image slightly to ensure all of the axis label is printed
scalefactor = 0.75;  % can modify this depending on fontsz etc

% -------------------------------------------------------------------------
% START CREATING PLOT
% -------------------------------------------------------------------------

figure1=gcf;
axes1 = gca;

set(gca,...
    'FontSize',fontsz_ax,...
    'FontName','Times')


% label xaxis
set(get(gca,'XLabel'),...
  % 'Interpreter','latex',...
    'FontSize',fontsz_xy,...
    'FontName','Times',...
    'Color',[0, 0, 0]);


% label yaxis
set(get(gca,'YLabel'),...
  % 'Interpreter','latex',...
    'FontSize',fontsz_xy,...
    'FontName','Times',...
    'Color',[0, 0, 0]);


% % insert legend
 %if exist(legend,'var')
 %legend(axes1,'show');
 legend1 = legend();
 set(legend1,...
     'FontSize',fontsz_legend,...
     'FontName','Times',...
   % 'Interpreter','latex',...
     'Location','SouthWest',...    %'EastOutside',...  % NorthEast
     'TextColor',[0,0,0],...
     'EdgeColor',[0,0,0],...
     'YColor',[0,0,0],...
     'XColor',[0,0,0]);        
 end

% rescale image slightly to ensure all of the axis label is printed
g = get(gca,'Position');
g(1:2) = g(1:2) + (1-scalefactor)/2*g(3:4);
g(3:4) = scalefactor*g(3:4);
set(gca,'Position',g);

% %For autocorrelation
% hold on
% plot(X1(:,1),zeros(size(X1(:,1))),'color',plot_colours(1,:))
% hold off

box(axes1,'on');

