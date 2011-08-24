
$.ajaxSetup( { cache: false });
var ajax_eyecandy = "<p>Loading...</p>";
    
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

$( function() {
    $( '#accordion' ).accordion( {
        autoHeight: false,
        collapsible: true,
        navigation: true
    } );
} );
