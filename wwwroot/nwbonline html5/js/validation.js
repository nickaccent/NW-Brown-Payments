	function setupValidation(formname,submitbutton,confirm,disableajax)
	{
	
	if(confirm)
		$(confirm).set({'opacity':0});
		
					var ddlRequired = new InputValidator('dropdown-required', {
					errorMsg: 'Please select an option from the dropdown.',
					test: function(field){
						return ((field.get('value') == ""));
						}
				});
					
		$$('.validation-advice').set({'opacity':0});
		$$('.validation-advice').set('morph', {
			duration: 800,
			transition: Fx.Transitions.Sine.easeOut
			});
			
			
		var formValidator = new Form.Validator($(formname), {
			onElementValidate: function(isValid, field, className, warn){
			      var validator = this.getValidator(className);
			     
				  if (!isValid){
					if(field.getNext('div.validation-advice'))
						field.getNext('div.validation-advice').dispose();
					
					var valMsg= new Element('div',{'class': 'validation-advice'});
					valMsg.set('text',validator.getError($(field)));
					valMsg.inject(field,'after');
					valMsg.set({'opacity':0.1});
					valMsg.morph({'opacity':1});
					valMsg.addEvent('click',function(event)
						{
					event.stop();
					 $(this).dispose();
					$(submitbutton).disabled=0;
						});
			    	  //$(field).getNext('div').set('text',validator.getError($(field)));
					  //$(field).getNext('div').set({'opacity':0.1});
			    	  //$(field).getNext('div').morph({'opacity':1});
			    	}
			    },
		    onFormValidate: function(valid,form,onsubmit)
		    {
			
		    	if(valid)
		    		{
						if(confirm)
						{
					   myResult = $(confirm);
                        
                        // Ajax (integrates with the validator).
                       var formRequest = new Form.Request(form,myResult,{resetForm:false});
                        formRequest.send();
						$(confirm).setStyles({'visibility':'visible','opacity':1,'display':'block'});
						}
						else
						{
							// Ajax (integrates with the validator).
						if(disableajax && disableajax==true)
						{
							form.submit();
						}
						else
						{
								form.send();
						}
						}
					
		    		}
			}
		});
		
		$(submitbutton).addEvent('click',function(event)
		{
			
			
			this.disabled=true;
			formValidator.validate();
			
		});
		
	Object.each($$('.form-field'),function(item,key,object)
			{
				object.addEvent('blur',function(event)
				{
					event.stop();
					formValidator.validateField(this,true);
				});
				
				object.addEvent('change',function(event)
						{
					event.stop();
					
					 if($(this).getNext('div.validation-advice'))
					 {
					 	 var msg= $(this).getNext('div.validation-advice');
						 msg.dispose();
					 }
					$(submitbutton).disabled=0;
						});
			});
						$$('.validation-advice').addEvent('click',function(event)
						{
					event.stop();
					 $(this).morph({'opacity':0,'visibility':'hidden'});
					$(submitbutton).disabled=0;
						});
						
						return formValidator;
                };
            