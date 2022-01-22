function letters = FindLetterImages(im)

    % wstępna obróbka obrazu
    im = double(im);
    im = 1 - (im-min(im, [], 'all')) / (max(im, [], 'all') - min(im, [], 'all'));
    im = rgb2gray(im);
    im = imfilter(im, [-1, -1, -1; -1, 9, -1; -1, -1, -1]/3);
    im(im<0)=0;
    im(im>1)=1;
    originalIm = im;
    
    % binaryzacja
    binary = imbinarize(im, 'adaptive', 'Sensitivity', 0.5);
    im = imbinarize(im .* binary, 0.1);
    im = bwmorph(im, 'clean');
    clear binary
    
    % usuwanie marginesów
    mask = ones(size(im));
    mask(1, :) = 0;
    mask(end, :) = 0;
    mask(:, 1) = 0;
    mask(:, end) = 0;
    im = im & imerode(mask, ones(15));
    clear mask;
    
    % wykrywanie linii
    mask = zeros(10);
    for i=1:15
        mask(7, i) = 1;
    end
    lineMask = imdilate(im, mask);
    lineMask = imdilate(lineMask, ones(5));
    %lineMask = imclose(lineMask, ones(5));
    lineMask = imclose(lineMask, mask);
    l = bwlabel(lineMask')';
    count = max(l, [], 'all');
    lineCount = 1;
    linesTemp = cell([count, 1]);
    area = sum(lineMask, 'all');
    
    for i=1:count
        if sum(l==i, 'all') > area/64
            linesTemp{lineCount} = (l==i) & im;
            lineCount = lineCount + 1;
        end
    end
    lineCount = lineCount-1;
    lines = cell([lineCount, 1]);
    originalLines = cell([lineCount, 1]);
    for i=1:lineCount
        cropped = CropImages(linesTemp{i}, originalIm, 50);
        lines{i} = cropped{1};
        originalLines{i} = cropped{2};
    end
    clear linesTemp linesMask;
    
    letters = cell([lineCount, 1]);
    
    mask = mask';
    
    % wykrywanie znaków
    for i=1:lineCount
        disp(string(i) + '/' + string(lineCount));
        letterMask = lines{i};
        %letterMask = bwmorph(letterMask, 'thicken', 1); 
         letterMask = imerode(letterMask, [0, 1, 0; 0, 1, 0; 0, 0, 0]);
%         letterMask = imfilter(letterMask, ones(3)/9);
%         letterMask(letterMask<0.12) = 0;
%         letterMask(letterMask>0.12) = 1;

        letterMask = imdilate(letterMask, mask);
%          letterMask = imdilate(letterMask, [0, 0, 0; 1, 1, 1; 0, 0, 0]);
        letterMask = imdilate(letterMask, [0, 1, 0; 0, 1, 0; 0, 1, 0]);
        letterMask = imclose(letterMask, [0, 1; 1, 1]);

        imwrite(lines{i}, 'testspace/' + string(i) + '.png'); %%%%%%%%%%%%%
        imwrite(letterMask, 'testspace/mask' + string(i) + '.png'); %%%%%%%%%%%%%
    
        area = sum(lines{i}, 'all');
        l = bwlabel(letterMask);
        count = max(l, [], 'all');
        letterCount = 1;
    
        tempLettersInLine = cell([letterCount, 1]);
        for j=1:count
            if sum(l==j, 'all') > area/100
                cropped = CropImages((l==j) & lines{i}, originalLines{i}, 5);
                tempLettersInLine{letterCount} = imresize(cropped{2}, [32, 16]);
                letterCount = letterCount + 1;
            end
        end
        letterCount = letterCount -1;
        lettersInLine = cell([letterCount, 1]);
        for j=1:letterCount
            lettersInLine{j} = tempLettersInLine{j};
            imwrite(lettersInLine{j}, 'testspace/letters/' + string(i) + "x" + string(j) + '.png'); %%%%%%%%%%%%%
        end
        clear tempLettersInLine;
        letters{i} = lettersInLine;
    end 

end