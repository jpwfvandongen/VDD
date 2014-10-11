
% function: XTPHASE.m
%
% Fig 3.16: Lotka-Volterra model (3.45a,b)

function XTPHASE()
    global h a b c 
   
    xm = 10; ym = 10; tm = 10;
    [fig1 fig2] = init_figures(xm,ym,tm);
    
    a = 2; 
    b = 1;
    c = .1;
    h = .001;
    t = 0;

    % --- Step-by-step method ---
    fprintf('No input value(s) will stop execution\n\n');
    [x y] = askvalues('x0,y0 = ');
    if isempty(x); return; end

    subplot_pnt('init', 2, 100, {'r','b'});    % line types: use { not [
    while abs(t-tm) > h/2
        [x y] = ImpEuler(x,y,t);
        t = t + h;
        subplot_pnt('add', 1, t, x, y);
        if x > -xm
            subplot_pnt('add', 2, x, y*xm/ym);
        end
    end
    subplot_pnt('flush');

    fprintf('t = %f\n', t);
    fprintf('x = %f\n', x);
    fprintf('y = %f\n', y);

    hold(fig1, 'off');
    hold(fig2, 'off');
end

function [fig1 fig2] = init_figures(xm,ym,tm)
    clf
    
    fig1 = subplot(1,2,1);
    axis([0 tm 0 xm]);
    axis('square');
    hold on
    plot(0,0,'r', 0,0,'b'); % points must be plotted before legend() is used
    legend('x','y');
    % plot([0 tm],[0 0],'k:');
    xlabel('t');
    ylabel('x and y');
    title('XT-plot');
    
    
    fig2 = subplot(1,2,2);
    axis([-xm xm 0 ym]);
    axis('square');
    hold on
    plot([-xm xm],[0  0],'k:');
    plot([0 0],[-ym  ym],'k:');
    xlabel('x');
    ylabel('dx/dt');
    title('Phase diagram');
end

function rv = fnf(x,y,t)
    global a c
    rv = 4-2*y;
end

function rv = fng(x,y,t)
    global b c
    rv = 12-3*x^2;
end

function [x y] = ImpEuler(x,y,t)
    global h
    c1 = h * fnf(x, y, t);
    d1 = h * fng(x, y, t);
    c2 = h * fnf(x + c1, y + d1, t + h);
    d2 = h * fng(x + c1, y + d1, t + h);
    x = x + (c1 + c2)/2;
    y = y + (d1 + d2)/2;
end

function subplot_pnt(mode, ifig, t, x, y)
    persistent nfig tbuf xbuf ybuf ibuf buflen lintypes
    
    switch mode
        case 'init'
            nfig     = ifig;
            buflen   = t;
            lintypes = x;
            tbuf = zeros(buflen,nfig);
            xbuf = zeros(buflen,nfig);
            ybuf = zeros(buflen,nfig);
            ibuf = ones(nfig,1);

        case 'add'
            i = ibuf(ifig);
            tbuf(i,ifig) = t;
            xbuf(i,ifig) = x;
            if nargin == 5; ybuf(i,ifig) = y; end;
            
            if i == buflen
                plotbuf(ifig,buflen);
                i = 1;
                tbuf(1,ifig) = t;    % To prevent gaps in the graph, start
                xbuf(1,ifig) = x;    % the buffer with the current point
                if nargin == 5; ybuf(1,ifig) = y; end;
            end
            ibuf(ifig) = i+1;
                
        case 'flush'  % plot the current content of the buffers
            for ifig = 1:nfig
                plotbuf(ifig,ibuf(ifig)-1);
            end
    end
    
    function plotbuf(ifig,len)
        subplot(1,nfig,ifig);
        plot(tbuf(1:len,ifig), xbuf(1:len,ifig), lintypes{ifig});
        if size(ybuf(1:len),1) > 0
            plot(tbuf(1:len,ifig), ybuf(1:len,ifig), 'b');
        end
        pause(1e-6);
    end
end


function [x y] = askvalues(requeststr)
    s = input(requeststr, 's');
    if isempty(s)
        x = []; y = [];
    else
        v = sscanf(s, '%f%f%f%1s');
        x  = v(1);
        y  = v(2);
    end
end

