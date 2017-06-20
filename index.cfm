<!---
	ToDo:
		1) unlink child
		2) after delete parent if the object is orphaned go to next highest object
		3) warn if child/parent has been orphaned
		4) disable 'link' in search results if its already a link of this object
		5) When creating a new object have an intermediate page with search results showing possible existing parents with option to select one or more instead of the one entered in the form
		6) Alternative names for an object
		7) Show orphaned objects
		8) File upload for content / view content
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
	<cfif len(url[key]) AND NOT listFindNoCase("view,edit,delete,link,unlink", key)>
		<cfset currentQueryString = listAppend(currentQueryString, "#lcase(key)#=#urlEncodedFormat(url[key])#", "&") />
	</cfif>
</cfloop>
<cfif listLast(url.path) NEQ url.p>
	<cfset url.path = listAppend(url.path, url.p) />
</cfif>

<cfif url.path eq url.p AND url.p neq 1>
	<cfset qThisPathToRoot = application.s.main.getAllPathsFromObjectToRoot(url.p) />
	<cfset thisReversePathToRoot = qThisPathToRoot.path />
	<cfset thisPathToRoot = "" />
	<cfloop from="#listLen(thisReversePathToRoot)#" to="1" index="i" step="-1">
		<cfset thisPathToRoot = listAppend(thisPathToRoot, listGetAt(thisReversePathToRoot, i)) />
	</cfloop>
	<cfset url.path = thisPathToRoot />
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
	<cfdump var="#url#">
	<cfdump var="#form#">
	<cflocation url="?#currentQueryString#&view=#form.id#" addToken="false" />
</cfif>

<!--- Search for parents --->
<cfif isDefined("form.searchParents")>
	<cfset searchParentsResults = application.s.main.searchParents(argumentCollection=form) />
	<cfset qParentsSearchResultsWithLinks = searchParentsResults />
	<cfset queryAddColumn(qParentsSearchResultsWithLinks, "link", "varchar", []) />
	<cfloop query="qParentsSearchResultsWithLinks">
		<cfset qPathsToRoot = application.s.main.getFirstPathFromObjectToRoot(qParentsSearchResultsWithLinks.id) />
		<cfset reversedPath = listRest(qPathsToRoot.path) />
		<cfset pathToRoot = "" />
		<cfloop from="#listLen(reversedPath)#" to="1" index="i" step="-1">
			<cfset pathToRoot = listAppend(pathToRoot, listGetAt(reversedPath, i)) />
		</cfloop>
		<cfset theLink = "<a href=""?p=#qParentsSearchResultsWithLinks.id#&parentName=#urlEncodedFormat(qParentsSearchResultsWithLinks.name)#&path=#pathToRoot#"">#name#</a>" />
		<cfset querySetCell(qParentsSearchResultsWithLinks, "name", theLink, qParentsSearchResultsWithLinks.currentRow) /> 
		<cfset linkLink = "<a href=""?#currentQueryString#&link=#qParentsSearchResultsWithLinks.id#"">Link</a>" />
		<cfset querySetCell(qParentsSearchResultsWithLinks, "link", linkLink, qParentsSearchResultsWithLinks.currentRow) /> 
	</cfloop>
	<cfset parentsSearchResults = application.queryToTable(searchParentsResults,	[
		{id: "ID"}, {name: "Name"}, {link: "Link"}
	]) />
</cfif>

<!--- Link To Parent --->
<cfif isDefined("url.link")>
	<cfset linkResult = application.s.main.setNewParent(url.p, url.link) />
</cfif>

<!--- Unlink From Parent --->
<cfif isDefined("url.unlink")>
	<cfset unlinkResult = application.s.main.deleteParent(url.p, url.unlink) />
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

<!--- Get Parents --->
<cfset qParents = application.s.main.getParents(url.p) />
<cfset qPathsToRoot = application.s.main.getAllPathsFromObjectToRoot(url.p) />
<cfset sPathsToRoot = structNew() />
<cfloop query="qPathsToRoot">
	<cfset thisPath =  listRest(qPathsToRoot.path) />
	<cfset key = listFirst(thisPath) />
	<cfset reversedPath = listRest(thisPath) />
	<cfset value = "" />
	<cfloop from="#listLen(reversedPath)#" to="1" index="i" step="-1">
		<cfset value = listAppend(value, listGetAt(reversedPath, i)) />
	</cfloop>
	<cfif NOT structKeyExists(sPathsToRoot, key)>
		<cfset structInsert(sPathsToRoot, key, value) />
	</cfif>
</cfloop>
<cfset reverseUrlPath = "" />
<cfloop from="#listLen(url.path)#" to="1" index="i" step="-1">
	<cfset reverseUrlPath = listAppend(reverseUrlPath, listGetAt(url.path, i)) />
</cfloop>
<cfset reverseUrlPath = listRest(reverseUrlPath) />
<cfif qParents.recordCount>
	<cfset qParentsWithLinks = qParents />
	<cfset queryAddColumn(qParentsWithLinks, "unlink", "varchar", []) />
	<cfloop query="qParents">
		<cfset parentInPath = listFind(reverseUrlPath, qParents.id) />
		<cfif parentInPath>
			<cfset thisParentPath = "" />
			<cfloop from="#parentInPath+1#" to="#listLen(reverseUrlPath)#" index="i">
				<cfset thisParentPath = listPrepend(thisParentPath, listGetAt(reverseUrlPath, i)) />
			</cfloop>
			<cfset parentsPath = thisParentPath />
		<cfelseif structKeyExists(sPathsToRoot, qParents.id)>
			<cfset parentsPath = sPathsToRoot[qParents.id] />
		<cfelse>
			<cfset parentsPath = "" />
		</cfif> 
		<cfset theLink = "<a href=""?p=#qParents.id#&parentName=#urlEncodedFormat(qParents.name)#&path=#parentsPath#"">#qParents.name#</a>" />
		<cfset querySetCell(qParentsWithLinks, "name", theLink, qParents.currentRow) />
		<cfset unlinkLink = "<a href=""?#currentQueryString#&unlink=#qParents.id#"">Unlink</a>" />
		<cfset querySetCell(qParentsWithLinks, "unlink", unlinkLink, qParents.currentRow) /> 
	</cfloop>
	<cfset parentOutput = application.queryToTable(qParentsWithLinks,	[
		{name: "Name"}, {children: "Count"}, {unlink: "Unlink"}
	]) />
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

<!--- Get: path objects --->
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
	
	<!--- VIEW: Export button --->
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

	<!--- VIEW: Object's Parents --->	
	<cfif qParents.recordCount>
		<hr />
		<h3>Parents</h3>
		#parentOutput#
		<cfif isDefined("unlinkResult")>
			<cfif unlinkResult>
				<p style="color: green">The parent was unlinked successfully!</p>
			<cfelse>
				<p style="color: red">The parent didn't unlink correctly. It probably didn't exist.</p>
			</cfif>
		</cfif>
	</cfif>

	<!--- VIEW: Link More Parents --->
	<h3>Link More Parents</h3>
	<form action="?#currentQueryString#" method="post">
		Search: <input type="text" name="search">
		Type:
		<select name="type">
			<option value="0">All</option>
			<cfloop query="qTypes">
				<option value="#qTypes.id#">#qTypes.name#</option>
			</cfloop>
		</select>
		<input type="submit" name="searchParents" value="Search">
	</form>
	<cfif isDefined("searchParentsResults")>
		<cfif searchParentsResults.recordCount>
			#parentsSearchResults#
		<cfelse>
			<p>No results!</p>
		</cfif>
	</cfif>
	<cfif isDefined("linkResult")>
		<cfif linkResult>
			<p style="color: green">The link was created successfully!</p>
		<cfelse>
			<p style="color: red">The link didn't work. It probably already exists.</p>
		</cfif>
	</cfif>

	<!--- VIEW: Object's Children --->	
	<cfif qObjects.recordCount>
		<hr />
		<h3>Children</h3>
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
						<form action="?#currentQueryString#" method="post">
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
	</cfif>

	<!--- VIEW: Create New Objects --->
	<hr />
	<h3>Create Object</h3>
	<form action="?#currentQueryString#" method="post">
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
