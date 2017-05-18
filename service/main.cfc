component output='false' {

	public query function getTypes() {
		local.queryService = new Query();
		local.queryService.setSQL("
			SELECT id, name
			FROM type
			WHERE id > 1
			ORDER BY name ASC
		");
		return local.queryService.execute().getResult();
	}

	public array function getPathObjects(required string path) {
		local.queryService = new Query();
		local.queryService.addParam(name = 'path', value = arguments.path, cfsqltype = 'cf_sql_integer', list=true);
		local.queryService.setSQL("
			SELECT id, name
			FROM object
			WHERE id IN ( :path )
		");
		local.aPath = listToArray(arguments.path);
		local.qPath = local.queryService.execute().getResult();
		local.aReturnPath = [];
		for(local.i=1; local.i <= arrayLen(local.aPath); local.i++) {
			local.name = "";
	    for(local.path in local.qPath) {
	    	if(local.aPath[local.i] == local.path.id) {
	        var local.name = local.path.name;
	      }
	    }
			arrayAppend(local.aReturnPath, {id: local.aPath[local.i], name: local.name});
    }
		return local.aReturnPath;
	}

	public boolean function deleteObject(required numeric id, required numeric parent) {
		//check no children
		
		local.queryService = new Query();
		local.queryService.addParam(name = 'id', value = arguments.id, cfsqltype = 'cf_sql_integer');
		local.queryService.addParam(name = 'parent', value = arguments.parent, cfsqltype = 'cf_sql_integer');

		local.queryService.setSQL("
			SELECT count(*) AS count
			FROM object_join
			WHERE parent_id = ( :id )
		");
		local.children = local.queryService.execute().getResult();
		
		if(local.children.count > 0) {
			return false;
		} else {
			local.queryService.setSQL("
				DELETE FROM object_join
				WHERE parent_id = ( :parent )
					AND child_id = ( :id )
			");
			local.queryService.execute().getResult();
	
			local.queryService.setSQL("
				DELETE FROM object
				WHERE id = ( :id )
			");
			local.queryService.execute().getResult();
			
			return true;
		}
	}

	public query function getObjectData(required numeric id) {
		local.queryService = new Query();
		local.queryService.addParam(name = 'id', value = arguments.id, cfsqltype = 'cf_sql_integer');
		local.queryService.setSQL("
			SELECT id, name
			FROM object
			WHERE id = ( :id )
		");
		return local.queryService.execute().getResult();
	}

	public query function getObjects(
		string object="",
		string parent="",
		string objectType="",
		string parentType=""
	) {
		local.queryService = new Query();
		if(isNumeric(arguments.object)) {
			local.queryService.addParam(name = 'objectId', value = arguments.object, cfsqltype = 'cf_sql_integer', null=yesNoFormat(arguments.object < 0));
			local.queryService.addParam(name = 'objectName', null=true);
		} else {
			local.queryService.addParam(name = 'objectName', value = arguments.object, cfsqltype = 'cf_sql_varchar', null=yesNoFormat(!len(arguments.object)));
			local.queryService.addParam(name = 'objectId', null=true);
		}
		if(isNumeric(arguments.parent)) {
			local.queryService.addParam(name = 'parentId', value = arguments.parent, cfsqltype = 'cf_sql_integer', null=yesNoFormat(arguments.parent < 0));
			local.queryService.addParam(name = 'parentName', null=true);
		} else {
			local.queryService.addParam(name = 'parentName', value = arguments.parent, cfsqltype = 'cf_sql_varchar', null=yesNoFormat(!len(arguments.parent)));
			local.queryService.addParam(name = 'parentId', null=true);
		}
		if(isNumeric(arguments.objectType)) {
			local.queryService.addParam(name = 'objectTypeId', value = arguments.objectType, cfsqltype = 'cf_sql_integer', null=yesNoFormat(arguments.objectType < 0));
			local.queryService.addParam(name = 'objectTypeName', null=true);
		} else {
			local.queryService.addParam(name = 'objectTypeName', value = arguments.objectType, cfsqltype = 'cf_sql_varchar', null=yesNoFormat(!len(arguments.objectType)));
			local.queryService.addParam(name = 'objectTypeId', null=true);
		}
		if(isNumeric(arguments.parentType)) {
			local.queryService.addParam(name = 'parentTypeId', value = arguments.parentType, cfsqltype = 'cf_sql_integer', null=yesNoFormat(arguments.parentType < 0));
			local.queryService.addParam(name = 'parentTypeName', null=true);
		} else {
			local.queryService.addParam(name = 'parentTypeName', value = arguments.parentType, cfsqltype = 'cf_sql_varchar', null=yesNoFormat(!len(arguments.parentType)));
			local.queryService.addParam(name = 'parentTypeId', null=true);
		}
		local.queryService.setSQL("
			SELECT
				o.id, p.name AS parent, o.name AS object, ot.name AS type,
				count(oj2.child_id) AS children
			FROM object p
			INNER JOIN object_join oj ON oj.parent_id = p.id
			INNER JOIN type pt ON pt.id = p.type_id
			INNER JOIN object o ON o.id = oj.child_id
			INNER JOIN type ot ON ot.id = o.type_id
			LEFT JOIN object_join oj2 ON oj2.parent_id = o.id
			WHERE (( :objectName ) IS NULL OR o.name = ( :objectName ))
				AND (( :objectId ) IS NULL OR o.id = ( :objectId ))
				AND (( :parentName ) IS NULL OR p.name = ( :parentName ))
				AND (( :parentId ) IS NULL OR p.id = ( :parentId ))
				AND (( :objectTypeName ) IS Null OR ot.name = ( :objectTypeName ))
				AND (( :objectTypeId ) IS Null OR ot.id = ( :objectTypeId ))
				AND (( :parentTypeName ) IS Null OR pt.name = ( :parentTypeName ))
				AND (( :parentTypeId ) IS Null OR pt.id = ( :parentTypeId ))
			GROUP BY o.id, p.name, o.name, ot.name
		");
		return local.queryService.execute().getResult();
	}

	public boolean function setObject(required string name, required numeric type, required numeric parent) {
		transaction {        
    	try {        
				local.queryService = new Query();
				local.queryService.addParam(name = 'name', value = arguments.name, cfsqltype = 'cf_sql_varchar');
				local.queryService.addParam(name = 'type', value = arguments.type, cfsqltype = 'cf_sql_integer');
				local.queryService.addParam(name = 'parent', value = arguments.parent, cfsqltype = 'cf_sql_integer');
				local.queryService.setSQL("
					INSERT INTO object (name, type_id)
					VALUES (
						( :name ),
						( :type )
					)
					SELECT @@IDENTITY AS 'id'
				");
				local.newObject = local.queryService.execute().getResult();
				local.queryService.addParam(name = 'child', value = local.newObject.id, cfsqltype = 'cf_sql_integer');
				local.queryService.setSQL("
					INSERT INTO object_join (parent_id, child_id)
					VALUES (
						( :parent ),
						( :child )
					)
				");
				local.queryService.execute().getResult();
    		transactionCommit();        
				return true;
    	} catch(any e) {        
    		transactionRollback();        
				return false;
    	}        
    }        
	}

}
