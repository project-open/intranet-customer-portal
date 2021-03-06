// General Settings
var todays_date = Date();


// SuperSelectBox Target Language
var tempIdCounter = 0;

/*
Ext.require([
    'Ext.form.field.File',
    'Ext.form.Panel',
    'Ext.window.MessageBox'
]);
*/


Ext.onReady(function(){

	// set local blank image 
	Ext.BLANK_IMAGE_URL = '/intranet/images/cleardot.gif';

	Ext.ux.form.FileUploadField.override({
	    onChange : function() {
        	var fullPath = this.getValue();
	        var lastIndex = fullPath.lastIndexOf('\\');
        	if (lastIndex == -1)
                	return;
	        var fileName = fullPath.substring(lastIndex + 1);
        	this.setValue(fileName);
    	    }
	});

	Ext.QuickTips.init();  
	Ext.form.Field.prototype.msgTarget = 'side';  

	Ext.apply(Ext.form.VTypes,{  
		sourceNotEmpty: function(val, field){  
		        try {  
				if ( 0 == field.getValue()) {return false;} else {return true;};  
		        } catch(e) {  
        		    return false;  
        		}        
		}, 
		sourceNotEmptyText: '<%=[lang::message::lookup "" intranet-customer-portal.Please_Provide_Source_Language "Please provide a value for Source Language"]%>'
	});  

	// ************** Panel: UploadedFiles Data Grid*** //

	Ext.define('UploadedFiles', {
	    extend: 'Ext.data.Model',
	    fields: [
        	{name: 'inquiry_files_id', type: 'string'},
	        {name: 'file_name', type: 'string'},
        	{name: 'source_language', type: 'string'},
	        {name: 'target_languages',  type: 'string'},
        	{name: 'deliver_date',  type: 'string'}
	    ]
	});

	uploadedFilesStore = new Ext.data.Store({
	    autoLoad: true,
	    id: 'uploadedFilesStore',
	    model: 'UploadedFiles',
	    proxy: {
        	type: 'ajax',
	        url: '/intranet-customer-portal/get-uploaded-files?inquiry_id=@inquiry_id;noquote@&security_token=@security_token;noquote@',
        	reader: {
	            type: 'json',
        	    root: 'files', 
		    totalProperty: 'totalCount'
	        }
	    }
	});

	uploadedFilesStore.load(function(records, operation, success) {
		// console.log('reloading uploadedFilesStore'); 
		if (0 == uploadedFilesStore.getTotalCount()) {
			// document.getElementById('tableUploadedFiles').style.display = 'none';
			// document.getElementById('titleUploadedFiles').style.display = 'none';
			// document.getElementById('sendButtons').style.display = 'none';
		} 

	});

	grid = new Ext.grid.GridPanel({
		id: 'gridUploadedFiles',
		renderTo: 'grid_uploaded_files',
		store: uploadedFilesStore,
		width: 515,
		height: 250,
		columns: [
        	    {header: "<%=[lang::message::lookup "" intranet-customer-portal.Id "Id"]%>", width: 25, dataIndex: 'inquiry_files_id', sortable: true},
        	    {header: "<%=[lang::message::lookup "" intranet-customer-portal.File "File"]%>", width: 100, dataIndex: 'file_name', sortable: true},
        	    {header: "<%=[lang::message::lookup "" intranet-customer-portal.Source_Languages "Source Languages"]%>", width: 100, dataIndex: 'source_language', sortable: true},
        	    {header: "<%=[lang::message::lookup "" intranet-customer-portal.Target_Languages "Target Languages"]%>", width: 200, dataIndex: 'target_languages', sortable: true},
        	    {header: "<%=[lang::message::lookup "" intranet-customer-portal.Deliver_Date "Delivery Date"]%>", width: 100, dataIndex: 'deliver_date', sortable: true}
        	]
	});

        // ************** Target Language *** //

       Ext.define('CustomerPortal.Category', {
            extend: 'Ext.data.Model',
            idProperty: 'category_id',          // The primary key of the category

            fields: [
                {type: 'string', name: 'category_id'},
                {type: 'string', name: 'tree_sortkey'},
                {type: 'string', name: 'category'},
                {type: 'string', name: 'category_type'},
                {type: 'string', name: 'category_translated'},
                {type: 'string', name: 'indent_class',
                // Determine the indentation level for each element in the tree
                convert: function(value, record) {
                        var     category = record.get('category_translated');
                        var     indent = (record.get('tree_sortkey').length / 8) - 1;
                        return 'extjs-indent-level-' + indent;
                }
                }
            ]
        });

        Ext.define('PO.data.CategoryStore', {
                extend: 'Ext.data.Store',
                category_from_id: function(category_id) {
                        if (null == category_id || '' == category_id) { return ''; }
                        var     result = 'Category #' + category_id;
                        var     rec = this.findRecord('category_id',category_id);
                        if (rec == null || typeof rec == "undefined") { return result; }
                        return rec.get('category_translated');
                }
        });

        var targetLanguageStore = Ext.create('PO.data.CategoryStore', {
                storeId:        'targetLanguageStore',
                remoteFilter:   true,
                model: 'CustomerPortal.Category',
                proxy: {
                        type: 'rest',
                        url: '/intranet-customer-portal/get-target-languages',
                        appendId: true,
                        extraParams: {
                                format: 'json',
                                category_type: '\'Intranet Translation Language\''
                        },
                        reader: { type: 'json', root: 'data' }
                }
        });


    var selectTargetLanguage = Ext.create('Ext.ux.form.field.BoxSelect', {
	id: 'target_language_id',
        fieldLabel: '<a href="@abbreviation_url;noquote@"><img src="/intranet/images/help_12_12.gif"></a> <%=[lang::message::lookup "" intranet-customer-portal.Target_Languages "Target Languages"]%>',
	labelAlign: 'top',
       	renderTo: 'form_target_languages',
        displayField: 'category_translated',
        width: 200,
        labelWidth: 150,
        store: targetLanguageStore,
	valueField: 'category_id', 
        queryMode: 'remote',
	blankText: '<%=[lang::message::lookup "" intranet-customer-portal.Please_Provide_Value "Please provide a value"]%>',
	allowBlank: false,
	forceSelection: true,
	hiddenName: 'target_language_ids',
	style: { "margin-right": "10px" },
        listeners: {
                change: function(targetLanguageForm, value){
                        var record = targetLanguageForm.findRecord('category_id', value);
                }
        },
        listConfig: {
        	getInnerTpl: function() {
                	return '<div class={indent_class}>{category_translated}</div>';
                }
        }

    });

        targetLanguageForm = new Ext.FormPanel({
            id:                 'targetLanguageForm_id',
            renderTo:           'form_target_languages',
            autoHeight:         true,
            height:             170,
	    border:false,
            style: { "margin-right": "10px" },
            items: [
		selectTargetLanguage
            ]
        });



        // ************** Upload Form *** //

	myuploadform = new Ext.FormPanel({
	        id: 'upload_file_form',
		renderTo: 'upload_file_placeholder',
		border:false,
                fileUpload: true,
                width: 240,
                autoHeight: true,
                defaults: {
                    anchor: '95%',
                    allowBlank: false,
                    msgTarget: 'side',
		    border:0
                },
                items:[
                 {
                    xtype: 'fileuploadfield',
		    id: 'upload_file',
		    name:  'upload_file',
                    emptyText: '<%=[lang::message::lookup "" intranet-customer-portal.Please_Select_Document "Please select document"]%>',
		    labelAlign: 'top',
		    fieldLabel: '<%=[lang::message::lookup "" intranet-customer-portal.File_To_Translate "File to translate"]%>',
                    buttonText: 'Browse',
		    listeners: {
			    'change': function(){
				// alert(this.value = this.value.replace("C:\\fakepath\\", ""));
				// this.setValue(this.value.replace("C:\\fakepath\\", ""));
				// this.setValue('vv');
    			    }
  		    }
                 }
		]
        });


	// ************** Date Picker *** // 

	input_delivery_date = new Ext.form.Date({
	    id: 'delivery_date',
	    renderTo: 'delivery_date_placeholder',
	    fieldLabel: '<%=[lang::message::lookup "" intranet-customer-portal.Delivery_Date "Delivery Date"]%>',
	    labelAlign: 'top',
	    labelWidth: 100,
	    width: 100,  
	    format: 'Y-m-d',
	    value: new Date(todays_date),
	    minValue: todays_date,
	    allowBlank: false,
	    style: { "margin-right": "10px" }
	    // anchor : '90%'
	});


        // ************** Form Handling *** //
        var clickHandlerSendFileandMetaData = function() {
		
		// var source_language = document.getElementById("form_source_language").elements[0].value;
		var source_language = sourceLanguageForm.getForm().findField('source_language').getRawValue();
		// console.log('source_language:' + source_language);
		var target_languages = targetLanguageForm.getForm().findField('target_language_id').getValue();

		// toDo: Improve
		var curr_date = input_delivery_date.getValue().getDate();
		var curr_month = input_delivery_date.getValue().getMonth() + 1;
		var curr_year = input_delivery_date.getValue().getFullYear();
		// console.log('curr_date: ' + curr_date + ', curr_month:' + curr_month + ', curr_year: ' + curr_year )
		var delivery_date = curr_year + '-' + curr_month + '-' + curr_date;

		if( myuploadform.getForm().isValid() && targetLanguageForm.getForm().isValid() && sourceLanguageForm.getForm().isValid() ){
			form_action=1;
			// console.log('delivery_date:' + delivery_date);
	                myuploadform.getForm().submit({
        	        	url: '/intranet-customer-portal/upload-files-form-action.tcl',
				params: 'source_language=' + source_language + '&target_languages=' + target_languages + '&delivery_date=' + delivery_date + '&inquiry_id=@inquiry_id;noquote@&security_token=@security_token;noquote@',
                	        waitMsg: '<%=[lang::message::lookup "" intranet-customer-portal.Uploading_File "Uploading file ..."]%>',
				success: function(response){
		                        document.getElementById('tableUploadedFiles').style.visibility='visible';
                		        document.getElementById('titleUploadedFiles').style.visibility='visible';
		                        document.getElementById('sendButtons').style.visibility='visible';
					document.getElementById('btnSendFileandMetaData').innerHTML = '<%=[lang::message::lookup "" intranet-customer-portal.Add_File_To_this_Quote "Add file to this quote"]%>'; 
					myuploadform.remove('upload_file', true);
					myuploadform.add(new Ext.ux.form.FileUploadField({
			                    xtype: 'fileuploadfield',
			                    id: 'upload_file',
			                    name:  'upload_file',
			                    emptyText: '<%=[lang::message::lookup "" intranet-customer-portal.Please_Select_Doc "Please select a document ..."]%>',
			                    labelAlign: 'top',
			                    fieldLabel: '<%=[lang::message::lookup "" intranet-customer-portal.File_To_Translate "File to translate"]%>',
			                    buttonText: 'Browse'
            				}));
					uploadedFilesStore.load();
				}, 
				failure: function(response){
				Ext.Msg.show({title:'Could not upload file', msg:'<%=[lang::message::lookup "" intranet-customer-portal.Err_File_Upload "<br/>The file you are trying to upload is either too large or you have already uploaded another file with an identical name"]%>'});
				} 
                 	});

			// reset form values 
                        // targetLanguageForm.getForm().findField('target_language_id').setValue('');
                        // document.getElementById('delivery_date').value = todays_date;
                        myuploadform.getForm().findField('upload_file').setValue('');
                 }
        };

        //add listener for button click
        Ext.EventManager.on('btnSendFileandMetaData', 'click', clickHandlerSendFileandMetaData);

        // ************** Handle CANCEL case *** //
        // Ext.EventManager.on('cancel', 'click', clickHandlerCancel);

	if ( 1 == @reset_p;noquote@ && 0 == @cancel_p;noquote@ ) {
		Ext.Msg.show({msg:'<%=[lang::message::lookup "" intranet-customer-portal.Thanks_For_Submitting "Thanks for submitting"]%>'});
	}	
        // console.log("cancel:@cancel_p;noquote@");
	if ( 1 == @cancel_p;noquote@ ) {
                Ext.Msg.show({
			msg:'<%=[lang::message::lookup "" intranet-customer-portal.Inquiry_Deleted "Your inquiry and all uploaded files have been deleted"]%>',
			buttons: Ext.MessageBox.OK,
			closable:true
		});
	}
	// console.log("store size: " + uploadedFilesStore.getTotalCount());
	document.getElementById('tableUploadedFiles').style.visibility='hidden';
	document.getElementById('titleUploadedFiles').style.visibility='hidden';
	document.getElementById('sendButtons').style.visibility='hidden';

        sourceLanguageForm = new Ext.FormPanel({
            id: 'sourceLanguageForm_id',
            renderTo: 'source_language_placeholder',
            autoHeight: true,
            width: 150,
	    border:false,
            style: { "margin-right": "10px" },
            items: [{
                xtype: 'combo',
		id: 'source_language',
                transform: 'source_language_id',
                allowBlank: false,
                blankText: 'Please provide a value',
                fieldLabel: '<a href="@abbreviation_url;noquote@"><img src="/intranet/images/help_12_12.gif"></a><%=[lang::message::lookup "" intranet-customer-portal.Source_Language "Source Language"]%>',
                labelAlign: 'top',
                labelWidth: 150,
                vtype:'sourceNotEmpty'
            }]
        });

});



