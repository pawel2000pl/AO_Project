function text=client(letters)

    import matlab.net.http.*
    import matlab.net.http.field.*
    
    data = jsondecode(jsonencode(letters));
%     letter2Json(letters, 'test.json');
%     data = jsondecode(fileread('test.json'));
    
    body = matlab.net.http.MessageBody(data);
    body.show
    
    contentTypeField = matlab.net.http.field.ContentTypeField('application/json');
    
    type1 = matlab.net.http.MediaType('text/*');
    type2 = matlab.net.http.MediaType('application/json','q','.5');
    acceptField = matlab.net.http.field.AcceptField([type1 type2]);
    
    header = [acceptField contentTypeField];
    
    request = matlab.net.http.RequestMessage('POST',header,body);
    
    response = request.send('http://localhost:2640/predict');
    
    show(response);

    text = response.Body.Data.text;


    fprintf('%s',text);

end