<cfset crlf = chr(13) & chr(10) />

<cfset output = "--Empty all tables
DELETE FROM value
DELETE FROM join_value
DELETE FROM meta
DELETE FROM join_meta
DELETE FROM object_join
DELETE FROM join_type
DELETE FROM object
DELETE FROM type

/* Select statements for checking data after import:
SELECT * FROM type
SELECT * FROM object
SELECT * FROM join_type
SELECT * FROM object_join
SELECT * FROM join_meta
SELECT * FROM meta
SELECT * FROM join_value
SELECT * FROM value
*/
" />

<!--- Tables --->
<cfset qTypes = application.s.data.getAllTypes() />
<cfset output &= crlf & "--Table: type" & crlf />
<cfloop query="qTypes">
	<cfset output &= "INSERT INTO type (id, name) VALUES (#qTypes.id#, '#application.escapeSQL(qTypes.name)#')" & crlf />
</cfloop>

<cfset qJoinTypes = application.s.data.getAllJoinTypes() />
<cfset output &= crlf & "--Table: join_type" & crlf />
<cfloop query="qJoinTypes">
	<cfset output &= "INSERT INTO join_type (id, name) VALUES (#qJoinTypes.id#, '#application.escapeSQL(qJoinTypes.name)#')" & crlf />
</cfloop>

<cfset qObjects = application.s.data.getAllObjects() />
<cfset output &= crlf & "--Table: object" & crlf />
<cfset output &= "SET IDENTITY_INSERT object ON" & crlf />
<cfloop query="qObjects">
	<cfset output &= "INSERT INTO object (id, name, type_id) VALUES (#qObjects.id#, '#application.escapeSQL(qObjects.name)#', #qObjects.type_id#)" & crlf />
</cfloop>
<cfset output &= "SET IDENTITY_INSERT object OFF" & crlf />

<cfset qMetas = application.s.data.getAllMetas() />
<cfset output &= crlf & "--Table: meta" & crlf />
<cfset output &= "SET IDENTITY_INSERT meta ON" & crlf />
<cfloop query="qMetas">
	<cfset output &= "INSERT INTO meta (id, name, display_name, type_id, object_id)	VALUES (#qMetas.id#, '#application.escapeSQL(qMetas.name)#', '#application.escapeSQL(qMetas.display_name)#', #qMetas.type_id#, #qMetas.object_id#)" & crlf />
</cfloop>
<cfset output &= "SET IDENTITY_INSERT meta OFF" & crlf />

<cfset qValues = application.s.data.getAllValues() />
<cfset output &= crlf & "--Table: value" & crlf />
<cfset output &= "SET IDENTITY_INSERT value ON" & crlf />
<cfloop query="qValues">
	<cfset output &= "INSERT INTO value (id, meta_id, value) VALUES (#qValues.id#, #qValues.meta_id#, '#application.escapeSQL(qValues.value)#')" & crlf />
</cfloop>
<cfset output &= "SET IDENTITY_INSERT value OFF" & crlf />

<cfset qObjectJoins = application.s.data.getAllObjectJoins() />
<cfset output &= crlf & "--Table: object_join" & crlf />
<cfset output &= "SET IDENTITY_INSERT object_join ON" & crlf />
<cfloop query="qObjectJoins">
	<cfset output &= "INSERT INTO object_join (id, parent_id, child_id, join_type_id) VALUES (#qObjectJoins.id#, #qObjectJoins.parent_id#, #qObjectJoins.child_id#, #qObjectJoins.join_type_id#)" & crlf />
</cfloop>
<cfset output &= "SET IDENTITY_INSERT object_join OFF" & crlf />

<cfset qJoinMetas = application.s.data.getAllJoinMetas() />
<cfset output &= crlf & "--Table: join_meta" & crlf />
<cfset output &= "SET IDENTITY_INSERT join_meta ON" & crlf />
<cfloop query="qJoinMetas">
	<cfset output &= "INSERT INTO join_meta (id, name, display_name, join_type_id, object_join_id) VALUES (#qJoinMetas.id#, '#application.escapeSQL(qJoinMetas.name)#', '#application.escapeSQL(qJoinMetas.display_name)#', #qJoinMetas.join_type_id#, #qJoinMetas.object_join_id#)" & crlf />
</cfloop>
<cfset output &= "SET IDENTITY_INSERT join_meta OFF" & crlf />

<cfset qJoinValues = application.s.data.getAllJoinValues() />
<cfset output &= crlf & "--Table: join_value" & crlf />
<cfset output &= "SET IDENTITY_INSERT join_value ON" & crlf />
<cfloop query="qJoinValues">
	<cfset output &= "INSERT INTO join_value (id, join_meta_id, value) VALUES (#qJoinValues.id#, #qJoinValues.join_meta_id#, '#application.escapeSQL(qJoinValues.value)#')" & crlf />
</cfloop>
<cfset output &= "SET IDENTITY_INSERT join_value OFF" & crlf />

<!--- Download SQL File --->
<cfheader name="Content-Disposition" value="attachment; filename=export.sql" />
<cfcontent variable="#toBinary(toBase64(output))#"  type="application/octet-stream">
<!---<cfcontent reset="true"><cfoutput><pre>#output#</pre></cfoutput><cfabort>--->
