
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
	} else if ($('select[name="' + class_name + '_1.location"]').val() == '') {
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
	var input_count = fieldset.prev();
	var element_name = fieldset.children('div').attr('id');
	var inputs = fieldset.children('div').children('div').children('input');
	var counter = inputs.length;
	var elements = inputs.parent();

	var add_button = '<a style="margin-bottom:10px;" class="btn btn-small" href="#" id="' + element_name + '_add_button"><i class="icon-plus"></i></a>';
	fieldset.children('div').prepend(add_button);


	// When add button is pressed, add a new field block.
	$('#' + element_name + '_add_button').live('click keypress', function(e) {
	    counter++;
	    input_count.attr('value', counter);

	    var new_element = elements.last().clone();

	    var names = new_element.find('*[name^="' + element_name + '"]');

	    $.each(names, function() {
		var name = $(this).attr('name');
		$(this).attr('name', name.replace(/\d+/, counter));
	    });

            var id = new_element.find('*[name$=".id"]');
            id.val('');
	    
	    // Clear old value from cloned element
	    new_element.find('input[type="text"]').val('');

	    fieldset.children('div').append(new_element);

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

