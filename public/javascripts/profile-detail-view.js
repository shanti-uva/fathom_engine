// dynamically alter the edit profile link based on the currently selected tab
function updateEditProfileURL(e) {
	var tabName = getTabName($(e.target));
	if( tabName ) {
		var targetURL = TARGET_PROFILE_BASE_URL + "?tab=" + tabName;
		$("#edit-profile-link").attr("href",targetURL);
	}
}

// dynamically alter the show profile link based on the currently selected tab
function updateShowProfileURL(e) {
	var tabName = getTabName($(e.target));
	if( tabName ) {
		var targetURL = TARGET_PROFILE_BASE_URL + "?tab=" + tabName;
		$("#cancel-button").attr("href",targetURL);		
		$("#tab").val(tabName);
	}
}

// determine the URL based on the tab element
function getTabName( tab ) {
	var targetAnchor = tab.attr('href');		
	var dashTab = targetAnchor.indexOf('-tab');

	// only respond to clicks on the tab buttons 
	if( dashTab == -1 ) return null;

	// remove '#' and trailing '-tab' 
	return targetAnchor.substr(1).substr(0,dashTab-1);
}

// POST a destroy message for this item	
function removeItem( removeItemURL, authToken ) {
	$.post( removeItemURL, { 'authenticity_token': authToken, '_method' : 'delete' }, updateList );
}

// POST the contents of the item field
function addItem( addItemURL, category, authToken ) {	
	var fieldSelector = '#add-item-field-'+category;
	var itemText = jQuery.trim($(fieldSelector).val());
	
	// don't post empty field
	if( itemText.length > 0 ) {
		$.post( addItemURL, { 'line_item[text]': itemText, 'line_item[category]': category, 'authenticity_token': authToken }, updateList );
		$(fieldSelector).val('');
	}
}

// callback to update the item list
function updateList( html ) {
	var updatedList = $(html);
	$('#'+updatedList.attr('id')).replaceWith(updatedList);	
}

function showLinkForm( form_url ) {
	$("#add-links-button").hide();
	$("#link-edit-panel").load( form_url );
	$("#link-edit-panel").show();
}

function hideLinkForm() {
	$("#link-edit-panel").hide();	
	$("#link-edit-panel").clearForm();
	$("#add-links-button").show();
}

