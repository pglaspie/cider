
$.ajaxSetup( { cache: false });
var ajax_eyecandy = "<p>Loading...</p>";

// Various class fixes for bootstrap
$(function() {
    // two of the 'div.label' things because FormFu can double up on 'label' classes (evil)
    $('div.label').removeClass('label');
    $('div.label').removeClass('label');
    $('div.checkbox').removeClass('checkbox').addClass('clearfix');
    $('input[type="checkbox"]').prev('label').addClass('checkbox-label');
    $('fieldset').wrap('<div class="well" />');

    // Make the alert messages closable 
    $('.alert-message').alert();
});


$(function() {
    
    //collapsable TODO integrate this with class collapsing functionality
    $('.collapsable').collapse('hide');
    $('.collapsable').on('hide', function() {
	$(this).prev().children('i').replaceWith('<i class="icon-chevron-right collapse-icon"></i>');
    });
    $('.collapsable').on('show', function() {
	$(this).prev().children('i').replaceWith('<i class="icon-chevron-down collapse-icon"></i>');
    });
});

/* Expand and collapse for browse list */
function handle_expand_click( object_id ) {
    var div_id = 'children_of_' + object_id;
    var div = $( '#' + div_id );
    var url = base_uri + '/list/children/' + object_id;
    div.html(ajax_eyecandy).load(url);
    div.slideDown('slow');
    var collapse_button = $( '#collapse_button_' + object_id );
    var expand_button = $( '#expand_button_' + object_id );
    expand_button.hide();
    collapse_button.show();
}

function handle_collapse_click( object_id ) {
    var div_id = 'children_of_' + object_id;
    var div = $( '#' + div_id );
    var collapse_button = $( '#collapse_button_' + object_id );
    var expand_button = $( '#expand_button_' + object_id );
    expand_button.show();
    collapse_button.hide();
    div.slideUp('slow');
}



/* Collapsable Item classes */
$(function() {
    
    // Loop through array of Item classes and enable collapsable functionality
    var classes = ['file_folders', 'containers', 'bound_volumes', 'three_dimensional_objects', 'audio_visual_media', 'documents', 'physical_images', 'digital_objects', 'browsing_objects'];

    $.each(classes, function() {
        var class_name = this;
	var form_class = '.' + class_name + '_form';
        var button_id = '#' + class_name + '_expand_button';

	$(button_id).live('click keypress', function() {
	    $(form_class).toggle('blind');
	});
	
	// Check if the first location select element is empty. If true, collapse class, otherwise, leave open.
	// Browsing Objects have no location so they get special treatment
	if (class_name == 'browsing_objects') {
	    if ($('input[name="' + class_name + '_1.pid"]').val() == '') {
		$(form_class).hide();
	    }
	} else if ($('input[name="' + class_name + '_1.location"]').val() == '') {
	    $(form_class).hide();
	} else { 
	    $(form_class).show();
	}
    });
});    

/* Add repeatable form elements */ 
$(function() {

    var repeatable_fieldsets = $('fieldset.repeatable');

    // Iterate through repeatable field sets, grab relevant nodes, and create add and remove buttons.
    $.each(repeatable_fieldsets, function() {
    	var fieldset = $(this);
    	
    	// XXX These element-finding routines would probably be better served by
    	//     using absolute selectors (e.g. ID attributes) vs. relative locations.
    	var input_count = fieldset.parent().prev();
    	var element_name = fieldset.children('div').attr('id');
    	var inputs = fieldset.children('div').children('div').children('input');
    	var counter = inputs.length;
    	var elements = inputs.parent();

    	var add_button = '<span style="margin-bottom:10px;" class="btn btn-small" id="' + element_name + '_add_button"><i class="icon-plus"></i></span >';
    	fieldset.children('div').prepend(add_button);


    	// When add button is pressed, add a new field block.
    	$('#' + element_name + '_add_button').live('click keypress', function(e) {
    	    counter++;
    	    input_count.attr('value', counter);
            console.log( "Value of input counter: " + input_count.attr('value'));

    	    var new_element = elements.last().clone();

    	    var names = new_element.find('*[name^="' + element_name + '"]');

    	    $.each(names, function() {
          		var name = $(this).attr('name');
    	    	$(this).attr('name', name.replace(/\d+/, counter));
    		
    	    	// Let its ID attribute (if it has one) match its name attribute.
    	    	if ( $(this).attr('id') ) {
    		        $(this).attr('id', $(this).attr('name') );
    	    	}
	    });

            var id = new_element.find('*[name$=".id"]');
            id.val('');
	    
	    
	    // Clear old value from cloned element
	    new_element.find('input[type="text"]').val('');
	    
	    fieldset.children('div').append(new_element);

            set_all_autocomplete_handlers(base_uri);

    	});

    });
});


$( function() {
    $( '#accordion' ).accordion( {
        autoHeight: false,
        collapsible: true,
        navigation: true
    } );
} );

/* Autocomplete-helper functions */

// set_autocomplete_handler: Given a CSS selector, turn all matching input fields into
//                           jQuery autocomplete fields that know how to talk to 
//                           CIDER's back end.
var set_autocomplete_handler = function( uri_base, selector, action, field_name ) {
    $( selector ).each( function(index) {
        $(this).autocomplete( {

           source: uri_base + "autocomplete/" + action,
           minLength: 2,
           select: function( event, ui ) {
              set_autocomplete_fields( event, ui, $(this), field_name );    
           },
           focus: function( event, ui ) {
              set_autocomplete_fields( event, ui, $(this), field_name );
          }
        } );

    // Immediately upon any value change, check whether the field has been cleared.
    // If so, also clear the appropriate hidden fields. This will delete the proper
    // DB associations when the form is submitted.
     $(this).bind("propertychange keyup input cut paste", function( event ) {
         if ( $(this).val() == '' ) {
             clear_autocomplete_fields( event, $(this), field_name );
         }    
    
      } );
    
    });
}

// set_all_autocomplete_handlers: Call set_autocomplete_handler on all the input
//                                fields we care about.
var set_all_autocomplete_handlers = function( uri_base ) {
    set_autocomplete_handler( uri_base, '.location', 'location', 'location' );
    set_autocomplete_handler( uri_base, '.geographic_term', 'geographic_term', 'term' );
    set_autocomplete_handler( uri_base, '.topic_term', 'topic_term', 'term' );
    set_autocomplete_handler( uri_base, '.authority_name', 'authority_name', 'name' );
}

// set_autocomplete_fields: Wire up the given text input to respond properly to
//                          jQuery autocomplete events.
var set_autocomplete_fields = function( event, ui, object, field_name ) {
    event.preventDefault();
    var textfield_name = object.attr('name');
    var name_field_id = textfield_name.substr( 0, textfield_name.length - 13 ) + field_name;
    var name_field = document.getElementById( name_field_id );
    name_field.value = ui.item.value;
    object.val( ui.item.label );
}


// clear_autocomplete_fields: Clear all hidden fields related to the given text input,
//                            such that the object'll be deleted on form submission.
var clear_autocomplete_fields = function( event, object, field_name ) {
    var textfield_name = object.attr('name');
    var name_field_id = textfield_name.substr( 0, textfield_name.length - 13 ) + field_name;
    var name_field = document.getElementById( name_field_id );
    name_field.value = '';
    console.log( name_field.value );
}    
