
$.ajaxSetup( { cache: false });
var ajax_eyecandy = "<p>Loading...</p>";
    

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


$( function() {
    $( '#accordion' ).accordion( {
        autoHeight: false,
        collapsible: true,
        navigation: true
    } );
} );
