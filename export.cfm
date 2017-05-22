<cfset output = "" />
<cfset crlf = chr(13) & chr(10) />

<cfset output &= "--Empty all tables" & crlf />
<cfset output &= "DELETE FROM object_join" & crlf />
<cfset output &= "DELETE FROM object" & crlf />
<cfset output &= "DELETE FROM type" & crlf />


<!--- Tables --->
<cfset qTypes = application.s.data.getAllTypes() />
<cfset output &= crlf & "--Table: type" & crlf />
<cfloop query="qTypes">
	<cfset output &= "INSERT INTO type (id, name) VALUES (#qTypes.id#, '#qTypes.name#')" & crlf />
</cfloop>


<cfset qJoinTypes = application.s.data.getAllJoinTypes() />


<cfset qObjects = application.s.data.getAllObjects() />
<cfset output &= crlf & "--Table: object" & crlf />
<cfset output &= "SET IDENTITY_INSERT object ON" & crlf />
<cfloop query="qObjects">
	<cfset output &= "INSERT INTO object (id, name, type_id) VALUES (#qObjects.id#, '#qObjects.name#', '#qObjects.type_id#')" & crlf />
</cfloop>
<cfset output &= "SET IDENTITY_INSERT object OFF" & crlf />


<cfset qMetas = application.s.data.getAllMetas() />
<cfset qValues = application.s.data.getAllValues() />


<cfset qObjectJoins = application.s.data.getAllObjectJoins() />
<cfset output &= crlf & "--Table: object_join" & crlf />
<cfset output &= "SET IDENTITY_INSERT object_join ON" & crlf />
<cfloop query="qObjectJoins">
	<cfset output &= "INSERT INTO object_join (id, parent_id, child_id) VALUES (#qObjectJoins.id#, '#qObjectJoins.parent_id#', '#qObjectJoins.child_id#')" & crlf />
</cfloop>
<cfset output &= "SET IDENTITY_INSERT object_join OFF" & crlf />


<cfset qJoinMetas = application.s.data.getAllJoinMetas() />
<cfset qJoinValues = application.s.data.getAllJoinValues() />


<!--- Download SQL File --->
<cfheader name="Content-Disposition" value="attachment; filename=export.sql" />
<cfcontent variable="#toBinary(toBase64(output))#"  type="application/octet-stream">
<!---<cfcontent reset="true"><cfoutput><pre>#output#</pre></cfoutput><cfabort>--->
