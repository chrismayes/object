<!---
	ToDo:
		search before create - use existing obj as child
		link obj to additional parent
		option to have alternative names for same object
--->

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
	<cfif len(url[key]) AND NOT listFindNoCase("view,edit,delete", key)>
		<cfset currentQueryString = listAppend(currentQueryString, "#lcase(key)#=#urlEncodedFormat(url[key])#", "&") />
	</cfif>
</cfloop>
<cfif listLast(url.path) NEQ url.p>
	<cfset url.path = listAppend(url.path, url.p) />
</cfif>

<!--- Submit add an object --->
<cfif isDefined("form.newObject")>
	<cfif NOT application.s.main.setObject(argumentCollection=form)>
		<cfoutput><span style="color: red">New object creation failed!</span><br /><br /></cfoutput>
	</cfif>
</cfif>

<!--- Submit edit an object --->
<cfif isDefined("form.updateObject")>
	<cfif NOT application.s.main.editObject(argumentCollection=form)>
		<cfoutput><span style="color: red">Object update failed!</span><br /><br /></cfoutput>
	</cfif>
	<cflocation url="?#currentQueryString#&view=#url.edit#" addToken="false" />
</cfif>

<!--- View object --->
<cfif isDefined("url.view") AND isNumeric(url.view)>
	<cfset objectData = application.s.main.getObjectMetaData(url.view)>
	<cfset relationshipData = application.s.main.getObjectJoinMetaData(url.view, url.p)>
</cfif>

<!--- Edit object --->
<cfif isDefined("url.edit") AND isNumeric(url.edit)>
	<cfset editObjectData = application.s.main.getObjectMetaData(url.edit)>
	<cfset editRelationshipData = application.s.main.getObjectJoinMetaData(url.edit, url.p)>
	<cfset metaFields = application.s.main.getMetaForObjectType(url.edit) />
	<cfset joinMetaFields = application.s.main.getJoinMetaForObjectJoinType(url.edit, url.p) />
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
<cfset parentObjectMetaData = application.s.main.getObjectMetaData(url.p)>
<cfif url.p neq 1 AND listLen(url.path) gte 2>
	<cfset objectRelationshipData = application.s.main.getObjectJoinMetaData(url.p, listGetAt(url.path, listLen(url.path)-1))>
</cfif>
<cfset qTypes = application.s.main.getTypes() />
<cfset qObjects = application.s.main.getObjects(object = url.o, parent = url.p, objectType = url.ot, parentType = url.pt) />
<cfset qObjectsWithLinks = qObjects />
<cfset queryAddColumn(qObjectsWithLinks, "view", "varchar", []) />
<cfset queryAddColumn(qObjectsWithLinks, "edit", "varchar", []) />
<cfset queryAddColumn(qObjectsWithLinks, "delete", "varchar", []) />
<cfloop query="qObjects">
	<cfset theLink = "<a href=""?p=#id#&parentName=#urlEncodedFormat(qObjects.object[qObjects.currentRow])#&path=#url.path#"">#qObjects.object[qObjects.currentRow]#</a>" />
	<cfset querySetCell(qObjectsWithLinks, "object", theLink, qObjects.currentRow) /> 
	<cfset viewLink = "<a href=""?#currentQueryString#&view=#qObjects.id[qObjects.currentRow]#"">View</a>" />
	<cfset querySetCell(qObjectsWithLinks, "view", viewLink, qObjects.currentRow) /> 
	<cfset editLink = "<a href=""?#currentQueryString#&edit=#qObjects.id[qObjects.currentRow]#"">Edit</a>" />
	<cfset querySetCell(qObjectsWithLinks, "edit", editLink, qObjects.currentRow) /> 
	<cfif qObjects.children[qObjects.currentRow] eq 0>
		<cfset deleteLink = "<a href=""?#currentQueryString#&delete=#qObjects.id[qObjects.currentRow]#"">Delete</a>" />
	<cfelse>
		<cfset deleteLink = "<span style=""color: silver"">Delete</span>" />
	</cfif>
	<cfset querySetCell(qObjectsWithLinks, "delete", deleteLink, qObjects.currentRow) /> 
</cfloop>
<cfset output = application.queryToTable(qObjectsWithLinks,	[
	{object: "Name"}, {type: "Description"}, {children: "Count"}, {view: "View"}, {edit: "Edit"}, {delete: "Delete"}
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
		<cfif isDefined("objectRelationshipData") AND NOT structIsEmpty(objectRelationshipData)>
			<td width="20">
			</td>
			<td valign="top">
				<b>Object Data:</b><br />
				ID: #parentObjectMetaData.id#<br />
				Name: #parentObjectMetaData.name#<br />
				<cfloop collection="#parentObjectMetaData.metadata#" item="key">
					<cfif len(key)>
						#key#:
						<cfif isArray(parentObjectMetaData.metadata[key])>
							<div style="display: inline-block; vertical-align: top;">
								<cfloop from="1" to="#arrayLen(parentObjectMetaData.metadata[key])#" index="i">
									#parentObjectMetaData.metadata[key][i]#<br />
								</cfloop>
							</div><br>
						<cfelse>
							#parentObjectMetaData.metadata[key]#<br />
						</cfif>
					</cfif>
				</cfloop>
				<br />
				<b>Relationship Data:</b><br />
				<cfloop collection="#objectRelationshipData.metadata#" item="key">
					<cfif len(key)>
						#key#:
						<cfif isArray(objectRelationshipData.metadata[key])>
							<div style="display: inline-block; vertical-align: top;">
								<cfloop from="1" to="#arrayLen(objectRelationshipData.metadata[key])#" index="i">
									#objectRelationshipData.metadata[key][i]#<br>
								</cfloop>
							</div><br>
						<cfelse>
							#objectRelationshipData.metadata[key]#<br>
						</cfif>
					</cfif>
				</cfloop>
			</td>
		</cfif>
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
				<cfif isDefined("objectData") AND NOT structIsEmpty(objectData)>
					<td width="20">
					</td>
					<td valign="top">
						<b>Object '#objectData.name#' Data (ID: #objectData.id#):</b><br />
						<cfloop collection="#objectData.metadata#" item="key">
							<cfif len(key)>
								#key#:
								<cfif isArray(objectData.metadata[key])>
									<div style="display: inline-block; vertical-align: top;">
										<cfloop from="1" to="#arrayLen(objectData.metadata[key])#" index="i">
											#objectData.metadata[key][i]#<br />
										</cfloop>
									</div><br />
								<cfelse>
									#objectData.metadata[key]#<br />
								</cfif>
							</cfif>
						</cfloop>
						<br />
						<b>Relationship Data:</b><br />
						<cfloop collection="#relationshipData.metadata#" item="key">
							<cfif len(key)>
								#key#:
								<cfif isArray(relationshipData.metadata[key])>
									<div style="display: inline-block; vertical-align: top;">
										<cfloop from="1" to="#arrayLen(relationshipData.metadata[key])#" index="i">
											#relationshipData.metadata[key][i]#<br />
										</cfloop>
									</div><br />
								<cfelse>
									#relationshipData.metadata[key]#<br />
								</cfif>
							</cfif>
						</cfloop>
						<br />
						<a href="?#currentQueryString#">Clear View</a>
					</td>
				</cfif>
				<!--- Edit Object --->
				<cfif isDefined("editObjectData") AND NOT structIsEmpty(editObjectData)>
					<td width="20">
					</td>
					<td valign="top">
						<h4>Edit Object (ID: #editObjectData.id#):</h4>
						<form action="" method="post">
							<!--- object fields --->
							Name: <input type="text" name="name" value="#editObjectData.name#"><br />
							<!--- meta fields --->
							<h4>Object Data</h4>
							<cfloop query="metaFields">
								#metaFields.display_name#: 
								<cfif metaFields.multiple>
									<cfset value = structKeyExists(editObjectData.metadata, metaFields.name) ? editObjectData.metadata[metaFields.name] : [] />
									<cfloop from="1" to="#arrayLen(value)#" index="i">
										<input type="text" name="#metaFields.name#_#i#" value="#value[i]#" size="120"><br />
									</cfloop>
									<input type="text" name="#metaFields.name#_#i#" value="" size="120"><br />
								<cfelse>
									<cfset value = structKeyExists(editObjectData.metadata, metaFields.name) ? editObjectData.metadata[metaFields.name] : "" />
									<input type="text" name="#metaFields.name#" value="#value#" size="120"><br />
								</cfif>
							</cfloop>
							<!--- join_meta fields --->
							<h4>Relationship Data</h4>
							<cfloop query="joinMetaFields">
								#joinMetaFields.display_name#:
								<cfif joinMetaFields.multiple>
									<cfset value = structKeyExists(editRelationshipData.metadata, joinMetaFields.name) ? editRelationshipData.metadata[joinMetaFields.name] : [] />
									<cfloop from="1" to="#arrayLen(value)#" index="i">
										<input type="text" name="#joinMetaFields.name#_#i#" value="#value[i]#" size="120"><br />
									</cfloop>
									<input type="text" name="#joinMetaFields.name#_#i#" value="" size="120"><br />
								<cfelse>
									<cfset value = structKeyExists(editRelationshipData.metadata, joinMetaFields.name) ? editRelationshipData.metadata[joinMetaFields.name] : "" />
									<input type="text" name="#joinMetaFields.name#" value="#value#" size="120"><br />
								</cfif>
							</cfloop><br />
							<input type="hidden" name="parent" value="#url.p#">
							<input type="hidden" name="id" value="#editObjectData.id#">
							<input type="submit" name="updateObject" value="Edit">
						</form>
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
