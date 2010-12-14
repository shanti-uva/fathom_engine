var bTextareaWasTinyfied = false; 

function setTextareaToTinyMCE(sEditorID) {
	var oEditor = document.getElementById(sEditorID);
	if(oEditor && !bTextareaWasTinyfied) {
		tinyMCE.execCommand('mceAddControl', true, sEditorID);
		bTextareaWasTinyfied = true;
	}
	 tinyMCE.execCommand('mceAddControl', true, 'review_content');
	return;
}

function unsetTextareaToTinyMCE(sEditorID) {
	var oEditor = document.getElementById(sEditorID);
	if(oEditor && bTextareaWasTinyfied) {
		tinyMCE.execCommand('mceRemoveControl', true, sEditorID);
		bTextareaWasTinyfied = false;
	}
	return;
}