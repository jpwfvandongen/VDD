
% function: XTPHASE.m
%

function XTPHASE()
    global h w e A 
   
    xm = 4; ym = 4; tm = 100;
    [fig1 fig2] = init_figures(xm,ym,tm);
    w = 0.5;
    e = 1;
    A = 0.4;
    h = .005;
    t = 0;

    % --- Step-by-step method ---
    fprintf('No input value(s) will stop execution\n\n');
    % e = input('e : ');
    A = input('A : ');
    w = input('w : ');
    [x y] = askvalues('x0,y0 = ');
    if isempty(x); return; end

    subplot_pnt('init', 2, 100, {'g','b'});    % line types: use { not [
    while abs(t-tm) > h/2
        [x y] = ImpEuler(x,y,t);
        t = t + h;
        subplot_pnt('add', 1, t, x);
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
    axis([0 tm -xm xm]);
    axis('square');
    hold on
    plot([0 tm],[0 0],'k:');
    xlabel('t');
    ylabel('x');
    title('XT-plot');
    
    fig2 = subplot(1,2,2);
    axis([-xm xm -xm xm]);
    axis('square');
    hold on
    plot([-xm xm],[0  0],'k:');
    plot([0 0],[-ym  ym],'k:');
    xlabel('x');
    ylabel('dx/dt');
    title('Phase diagram');
end

function rv = fnf(x,y,t)
    rv = y;
end

function rv = fng(x,y,t)
    global w A e
    rv = A*sin(w*t)-e*((y^2)-1)*y-x;
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

function subplot_pnt(mode, ifig, t, x)
    persistent nfig tbuf xbuf ibuf htxt buflen lintypes
    
    switch mode
        case 'init'
            nfig    = ifig;
            buflen  = t;
            lintypes = x;
            tbuf = zeros(buflen,nfig);
            xbuf = zeros(buflen,nfig);
            ibuf = ones(nfig,1);

        case 'add'
            i = ibuf(ifig);
            tbuf(i,ifig) = t;
            xbuf(i,ifig) = x;
            if i == buflen
                plotbuf(ifig,buflen);
                i = 1;
                tbuf(1,ifig) = t;    % To prevent gaps, let the next part
                xbuf(1,ifig) = x;    % start on the last point
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
        pause(1e-6);
    end
end


function [x y] = askvalues(requeststr)
    s = input(requeststr, 's');
    if isempty(s)
        x = []; y = [];
    else
        v = sscanf(s, '%f%*[ ,]%f');
        x  = v(1);
        y  = v(2);
    end
end

