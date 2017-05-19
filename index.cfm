<!--- Setup --->
<cfparam name="url.o" default="" /><!--- object --->
<cfparam name="url.p" default="" /><!--- parent --->
<cfparam name="url.ot" default="" /><!--- object type --->
<cfparam name="url.pt" default="" /><!--- parent type --->
<cfparam name="url.path" default="" /><!--- parent type --->
<cfparam name="url.parentName" default="#application.rootName#" />
<cfif len(url.o) eq 0 AND len(url.p) eq 0 AND len(url.ot) eq 0 AND len(url.pt) eq 0>
	<cfset url.p = 1 />
	<cfset url.path = 1 />
</cfif>
<cfset currentQueryString = "" />
<cfloop collection="#url#" item="key">
	<cfif len(url[key]) AND NOT listFindNoCase("view,delete", key)>
		<cfset currentQueryString = listAppend(currentQueryString, "#lcase(key)#=#urlEncodedFormat(url[key])#", "&") />
	</cfif>
</cfloop>
<cfif listLast(url.path) NEQ url.p>
	<cfset url.path = listAppend(url.path, url.p) />
</cfif>

<!--- Add an object --->
<cfif isDefined("form.newObject")>
	<cfif NOT application.s.main.setObject(argumentCollection=form)>
		<cfoutput><span style="color: red">New object creation failed!</span><br /><br /></cfoutput>
	</cfif>
</cfif>

<!--- View object --->
<cfif isDefined("url.view") AND isNumeric(url.view)>
	<cfset objectData = application.s.main.getObjectData(url.view)>
</cfif>

<!--- Delete an object --->
<cfif isDefined("url.delete") AND isNumeric(url.delete)>
	<cfset objectDelete = application.s.main.getObjectData(url.delete)>
	<cfif objectDelete.recordCount>
		<cfset objectDeleted = application.s.main.deleteObject(url.delete, url.p)>
		<cfif objectDeleted>
			<cflocation url="?#currentQueryString#" />
		</cfif>
	</cfif>
</cfif>

<!--- Get objects --->
<cfset parentObjectData = application.s.main.getObjectData(url.p)>
<cfset qTypes = application.s.main.getTypes() />
<cfset qObjects = application.s.main.getObjects(object = url.o, parent = url.p, objectType = url.ot, parentType = url.pt) />
<cfset qObjectsWithLinks = qObjects />
<cfset queryAddColumn(qObjectsWithLinks, "view", "varchar", []) />
<cfset queryAddColumn(qObjectsWithLinks, "delete", "varchar", []) />
<cfloop query="qObjects">
	<cfset theLink = "<a href=""?p=#id#&parentName=#urlEncodedFormat(qObjects.object[qObjects.currentRow])#&path=#url.path#"">#qObjects.object[qObjects.currentRow]#</a>" />
	<cfset querySetCell(qObjectsWithLinks, "object", theLink, qObjects.currentRow) /> 
	<cfset viewLink = "<a href=""?#currentQueryString#&view=#qObjects.id[qObjects.currentRow]#"">View</a>" />
	<cfset querySetCell(qObjectsWithLinks, "view", viewLink, qObjects.currentRow) /> 
	<cfif qObjects.children[qObjects.currentRow] eq 0>
		<cfset deleteLink = "<a href=""?#currentQueryString#&delete=#qObjects.id[qObjects.currentRow]#"">Delete</a>" />
	<cfelse>
		<cfset deleteLink = "<span style=""color: silver"">Delete</span>" />
	</cfif>
	<cfset querySetCell(qObjectsWithLinks, "delete", deleteLink, qObjects.currentRow) /> 
</cfloop>
<cfset output = application.queryToTable(qObjectsWithLinks,	[
	{object: "Name"}, {type: "Description"}, {children: "Count"}, {view: "View"}, {delete: "Delete"}
]) />

<!--- Get path objects --->
<cfset aPathObjects = application.s.main.getPathObjects(url.path) />



<!--- ********VIEWS********* --->
<cfoutput>

	<!--- VIEW: Path To Object --->
	<cfset newPath = "" />
	<cfloop from="1" to="#arrayLen(aPathObjects)#" index="i">
		<cfif aPathObjects[i].id eq 1>
			<cfif arrayLen(aPathObjects) eq 1>
				<b>#application.rootName#</b>
			<cfelse>
				<a href="?"><b>#application.rootName#</b></a>
			</cfif>
		<cfelseif i eq arrayLen(aPathObjects)>
			| <b>#aPathObjects[i].name#</b>
		<cfelse>
			| <a href="?p=#aPathObjects[i].id#&parentName=#urlEncodedFormat(aPathObjects[i].name)#&path=#newPath#"><b>#aPathObjects[i].name#</b></a>
		</cfif>
		<cfset newPath = listAppend(newPath, aPathObjects[i].id) />
	</cfloop>
	
	<!--- Export --->
	<div style="float:right; position:relative">
		<a href="export.cfm">Export</a>
	</div>

	<!--- VIEW: Object Details --->
	<cfif url.p neq 1>
		<hr />
		ID = #parentObjectData.id#<br />
		Name = #parentObjectData.name#<br />
	</cfif>

	<!--- VIEW: Object's Children --->	
	<hr />
	<cfif qObjects.recordCount>
		<h3>Objects</h3>
		<table>
			<tr>
				<td valign="top">
					#output#
				</td>
				<!--- View Object --->
				<cfif isDefined("objectData") AND objectData.recordCount>
					<td width="20">
					</td>
					<td valign="top">
						<b>Object Data:</b><br />
						ID = #objectData.id#<br />
						Name = #objectData.name#<br /><br />
						<a href="?#currentQueryString#">Clear View</a>
					</td>
				</cfif>
				<!--- Delete Object --->
				<cfif isDefined("objectDeleted")>
					<td width="20">
					</td>
					<td valign="top">
						<span style="color: red">Delete object failed!</span><br />
					</td>
				</cfif>
			</tr>
		</table>


	<!--- VIEW: Create New Objects --->
	<hr />
	</cfif>
	<h3>Create Object</h3>
	<form action="" method="post">
		Name: <input type="text" name="name">
		Type:
		<select name="type">
			<cfloop query="qTypes">
				<option value="#qTypes.id#">#qTypes.name#</option>
			</cfloop>
		</select>
		<input type="hidden" name="parent" value="#url.p#">
		<input type="submit" name="newObject" value="Create">
	</form>
</cfoutput>
