% function: PHASE.m
%           (source: 2PHASE.BAS)
%

function PHASE()

    xm = 15; ym = 15;
    init_figure(xm, ym);
    
    % --- Step-by-step method ---
    fprintf('No input value will stop execution\n\n');
        
    while (1)
        [x y] = askvalues('x0,y0 =');

        if isempty(x); break; end
        
        t = 0;
        h = .005;
        plot_pnt('init', 50, 'r-');
        
        fprintf('Hit ENTER to stop\n');
        kbhit('init');
        while (1)
            [x y] = ImpEuler(x,y,h);
            t = t+h;
            plot_pnt('add', x,y);
            
            if kbhit == 10      % 10 = ENTER key
                input('');      % flush the last ENTER typed
                break;
            end
        end
        kbhit('stop');
        plot_pnt('flush');
    end
    hold off
end

function init_figure(xm,ym)
    clf;
    axis([-xm xm -ym ym]);
    hold on;
    plot([-xm xm],[0 0], 'k');
    plot([0 0],[-ym ym], 'k');
    xlabel('x');
    ylabel('y');
    title('2PHASE');

    % --- Plotting the direction field ---
    p = 32; % was 25
    Px = zeros((p+2)^2,1); Py = zeros((p+2)^2,1);
    vx = zeros((p+2)^2,1); vy = zeros((p+2)^2,1);
    i = 1;
    for y = ym : -2*ym/p : -ym
        for x = -xm : 2*xm/p : xm
            x1 = fnf(x,y)/xm;
            y1 = fng(x,y)/ym;
            s  = p*sqrt(x1^2 + y1^2);
            x2 = fnf(x,y)/s;
            y2 = fng(x,y)/s;

            Px(i) = x;  Py(i) = y;
            vx(i) = x2; vy(i) = y2;
            i = i+1;
        end
    end
    quiver(Px, Py, vx, vy, 0.5, 'b');
    commandwindow();  % Open Command Window, or select it if already open
end


function rv = fnf(x,y)
    rv = 4-2*y;
end

function rv = fng(x,y)
    rv =  12-3*x^2;
end

function [x y] = ImpEuler(x,y,h)
    c1 = h * fnf(x, y);
    d1 = h * fng(x, y);
    c2 = h * fnf(x + c1, y + d1);
    d2 = h * fng(x + c1, y + d1);
    x = x + (c1 + c2)/2;
    y = y + (d1 + d2)/2;
end

function [x y] = askvalues(requeststr)
    s = input(requeststr, 's');
    if isempty(s)
        x = []; y = [];
    else
        xy = sscanf(s, '%f%*[ ,]%f');
        x = xy(1);
        y = xy(2);
    end
end


function plot_pnt(mode, t, x)
    persistent tbuf xbuf ibuf buflen lintype
    
    switch mode
        case 'init'
            buflen  = t;    % now t = plot buffer length
            lintype = x;    %     x = linetype, ie 'r.-'
            tbuf = zeros(buflen,1);
            xbuf = zeros(buflen,1);
            ibuf = 1;
            
        case 'add'
            tbuf(ibuf) = t;
            xbuf(ibuf) = x;
            if ibuf == buflen
                plotbuf(buflen);
                ibuf = 1;
                tbuf(1) = t;    % To prevent gaps, let the next part
                xbuf(1) = x;    % start with the last point
            end
            ibuf = ibuf+1;
                
        case 'flush'  % plot the current content of the buffer
            plotbuf(ibuf-1);
    end
    
    function plotbuf(len)
        plot(tbuf(1:len), xbuf(1:len), lintype);    % 'Markersize', 5);
        pause(1e-6);
    end
end


