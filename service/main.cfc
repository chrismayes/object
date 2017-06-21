component output='false' {

	public boolean function deleteObjectMetaFields(objectId) {
		deleteObjectMetaData(arguments.objectId);
		local.queryService = new Query();
		local.queryService.addParam(name = 'id', value = arguments.objectId, cfsqltype = 'cf_sql_integer');
		local.queryService.setSQL("
			DELETE FROM meta
			WHERE object_id = ( :id )
		");
		local.queryService.execute();
		return true;
	}

	public boolean function deleteObjectMetaData(objectId) {
		local.queryService = new Query();
		local.queryService.addParam(name = 'id', value = arguments.objectId, cfsqltype = 'cf_sql_integer');
		local.queryService.setSQL("
			DELETE FROM value
			WHERE meta_id IN (
				SELECT id
				FROM meta
				WHERE object_id = ( :id )
			)
		");
		local.queryService.execute();
		return true;
	}

	public boolean function deleteObjectJoinMetaFields(child, parent) {
		local.objectJoin = getObjectJoin(arguments.child, arguments.parent);
		deleteObjectJoinMetaData(arguments.child, arguments.parent);
		local.queryService = new Query();
		local.queryService.addParam(name = 'id', value = local.objectJoin.id, cfsqltype = 'cf_sql_integer');
		local.queryService.setSQL("
			DELETE FROM join_meta
			WHERE object_join_id = ( :id )
		");
		local.queryService.execute();
		return true;
	}

	public boolean function deleteObjectJoinMetaData(objectId, parent) {
		local.queryService = new Query();
		local.queryService.addParam(name = 'id', value = arguments.objectId, cfsqltype = 'cf_sql_integer');
		local.queryService.addParam(name = 'parent', value = arguments.parent, cfsqltype = 'cf_sql_integer');
		local.queryService.setSQL("
			DELETE FROM join_value
			WHERE join_meta_id IN (
				SELECT jm.id
				FROM join_meta jm
				INNER JOIN object_join oj ON oj.id = jm.object_join_id
				WHERE oj.child_id = ( :id )
					AND oj.parent_id = ( :parent )
			)
		");
		local.queryService.execute();
		return true;
	}

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

	public query function getJoinTypes() {
		local.queryService = new Query();
		local.queryService.setSQL("
			SELECT id, name
			FROM join_type
			ORDER BY name ASC
		");
		return local.queryService.execute().getResult();
	}

	public query function getMetaForObjectType(objectId) {
		local.queryService = new Query();
		local.queryService.addParam(name = 'id', value = arguments.objectId, cfsqltype = 'cf_sql_integer');
		local.queryService.setSQL("
			SELECT DISTINCT m.name, m.display_name, m.multiple, m.sequence, m.type_id
			FROM object o
			INNER JOIN type t ON t.id = o.type_id
			INNER JOIN meta m ON m.type_id = t.id
			WHERE o.id = ( :id )
			ORDER BY sequence ASC, name ASC
		");
		return local.queryService.execute().getResult();
	}

	public query function getMetaForObject(objectId) {
		local.queryService = new Query();
		local.queryService.addParam(name = 'id', value = arguments.objectId, cfsqltype = 'cf_sql_integer');
		local.queryService.setSQL("
			SELECT m.id, m.name, m.display_name, m.multiple, m.sequence, m.type_id
			FROM object o
			INNER JOIN meta m ON m.object_id = o.id
			WHERE o.id = ( :id )
			ORDER BY sequence ASC, name ASC
		");
		return local.queryService.execute().getResult();
	}

	public query function getJoinMetaForObjectJoinType(objectId, parentId) {
		local.queryService = new Query();
		local.queryService.addParam(name = 'objectId', value = arguments.objectId, cfsqltype = 'cf_sql_integer');
		local.queryService.addParam(name = 'parentId', value = arguments.parentId, cfsqltype = 'cf_sql_integer');
		local.queryService.setSQL("
			SELECT DISTINCT jm.name, jm.display_name, jm.multiple, jm.sequence, jm.join_type_id, jm.direction
			FROM object_join oj
			INNER JOIN join_type jt ON jt.id = oj.join_type_id
			INNER JOIN join_meta jm ON jm.join_type_id = jt.id
			WHERE oj.parent_id = ( :parentId )
				AND oj.child_id = ( :objectId )
			ORDER BY sequence ASC, name ASC
		");
		return local.queryService.execute().getResult();
	}

	public query function getJoinMetaForObjectJoin(objectId, parentId) {
		local.queryService = new Query();
		local.queryService.addParam(name = 'objectId', value = arguments.objectId, cfsqltype = 'cf_sql_integer');
		local.queryService.addParam(name = 'parentId', value = arguments.parentId, cfsqltype = 'cf_sql_integer');
		local.queryService.setSQL("
			SELECT jm.id, jm.name, jm.display_name, jm.multiple, jm.sequence, jm.direction, jm.join_type_id
			FROM object_join oj
			INNER JOIN join_meta jm ON jm.object_join_id = oj.id
			WHERE oj.parent_id = ( :parentId )
				AND oj.child_id = ( :objectId )
			ORDER BY sequence ASC, name ASC
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

		transaction {        
    	try {
				if(local.children.count > 0) {
					return false;
				} else {
					deleteObjectMetaFields(arguments.id);
					deleteObjectJoinMetaFields(arguments.id, arguments.parent);

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
				}
	   		transactionCommit();
				return true;
	   	} catch(any e) {
	   		transactionRollback();
	   		writeDump(e);abort;
				return false;
	   	}
		}
	}

	public query function getObjectData(required numeric id) {
		local.queryService = new Query();
		local.queryService.addParam(name = 'id', value = arguments.id, cfsqltype = 'cf_sql_integer');
		local.queryService.setSQL("
			SELECT o.id, o.name, o.type_id
			FROM object o
			WHERE o.id = ( :id )
		");
		return local.queryService.execute().getResult();
	}

	public query function getObjectJoin(required numeric childId, required numeric parentId) {
		local.queryService = new Query();
		local.queryService.addParam(name = 'childId', value = arguments.childId, cfsqltype = 'cf_sql_integer');
		local.queryService.addParam(name = 'parentId', value = arguments.parentId, cfsqltype = 'cf_sql_integer');
		local.queryService.setSQL("
			SELECT oj.id, oj.join_type_id
			FROM object_join oj
			WHERE oj.child_id = ( :childId )
				AND oj.parent_id = ( :parentId )
		");
		return local.queryService.execute().getResult();
	}

	public struct function getObjectMetaData(required numeric id) {
		local.queryService = new Query();
		local.queryService.addParam(name = 'id', value = arguments.id, cfsqltype = 'cf_sql_integer');
		local.queryService.setSQL("
			SELECT o.id, o.name, m.display_name AS [key], v.value, m.multiple
			FROM object o
			LEFT JOIN meta m ON m.object_id = o.id
			LEFT JOIN value v ON v.meta_id = m.id
			WHERE o.id = ( :id )
		");
		return valueQueryToStruct(local.queryService.execute().getResult());
	}

	public struct function getObjectJoinMetaData(required numeric objectId, required numeric parentId) {
		local.queryService = new Query();
		local.queryService.addParam(name = 'objectId', value = arguments.objectId, cfsqltype = 'cf_sql_integer');
		local.queryService.addParam(name = 'parentId', value = arguments.parentId, cfsqltype = 'cf_sql_integer');
		local.queryService.setSQL("
			SELECT oj.id, m.display_name AS [key], v.value, m.multiple
			FROM object_join oj
			LEFT JOIN join_meta m ON m.object_join_id = oj.id
			LEFT JOIN join_value v ON v.join_meta_id = m.id
			WHERE oj.child_id = ( :objectId )
				AND oj.parent_id = ( :parentId )
		");
		return valueQueryToStruct(local.queryService.execute().getResult());
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
			ORDER BY o.name ASC
		");
		return local.queryService.execute().getResult();
	}

	public query function getParents(required numeric objectId) {
		local.queryService = new Query();
		local.queryService.addParam(name = 'objectId', value = arguments.objectId, cfsqltype = 'cf_sql_integer');
		local.queryService.setSQL("
			SELECT p.id, p.name, p.type_id, count(ch.id) AS children
			FROM object_join oj
			INNER JOIN object p ON p.id = oj.parent_id
			LEFT JOIN object_join ch ON ch.parent_id = oj.parent_id
			WHERE oj.child_id = ( :objectId )
				AND oj.parent_id != 1
			GROUP BY p.id, p.name, p.type_id
			ORDER BY p.name ASC
		");
		return local.queryService.execute().getResult();
	}

	public query function getAllTreePathsFromRoot() {
		local.queryService = new Query();
		local.queryService.setSQL("
			;WITH graph
				AS (SELECT id, parent_id, child_id, 1 as 'level', CONCAT(CAST(parent_id as nvarchar(max)), ',', CAST(child_id as nvarchar(max))) as path
					FROM object_join
					WHERE parent_id = 1
					UNION ALL
					SELECT oj.id, oj.parent_id, oj.child_id, level + 1 as 'level', CONCAT ( path, ',', CAST(oj.child_id as nvarchar(max))) as 'path'
					FROM object_join oj WITH (NOLOCK)
					INNER JOIN graph ON oj.parent_id = graph.child_id
					WHERE oj.child_id NOT IN (SELECT tmp.id FROM CSVToTable(graph.path) tmp )
				)
			SELECT g.path
			FROM graph g
			WHERE EXISTS (
				SELECT 1
				FROM graph g2
				WHERE g2.child_id = g.parent_id
				AND g2.Level < g.level
			)
		");
		return local.queryService.execute().getResult();
	}

	public query function getAllPathsFromObjectToRoot(required numeric objectId) {
		local.queryService = new Query();
		local.queryService.addParam(name = 'objectId', value = arguments.objectId, cfsqltype = 'cf_sql_integer');
		local.queryService.setSQL("
			;WITH graph
				AS (SELECT id, parent_id, child_id, ( :objectId ) as 'level', CONCAT(CAST(child_id as nvarchar(max)), ',', CAST(parent_id as nvarchar(max))) as path
					FROM object_join
					WHERE child_id = ( :objectId )
					UNION ALL
					SELECT oj.id, oj.parent_id, oj.child_id, level + ( :objectId ) as 'level', CONCAT ( path, ',', CAST(oj.parent_id as nvarchar(max))) as 'path'
					FROM object_join oj WITH (NOLOCK)
					INNER JOIN graph ON oj.child_id = graph.parent_id
					WHERE oj.parent_id NOT IN (SELECT tmp.id FROM CSVToTable(graph.path) tmp )
				)
			SELECT g.path
			FROM graph g
			WHERE EXISTS (
				SELECT 1
				FROM graph g2
				WHERE g2.parent_id = g.child_id
				AND g2.Level < g.level
			)
			AND parent_id = 1
		");
		return local.queryService.execute().getResult();
	}

	public query function getFirstPathFromObjectToRoot(required numeric objectId) {
		local.queryService = new Query();
		local.queryService.addParam(name = 'objectId', value = arguments.objectId, cfsqltype = 'cf_sql_integer');
		local.queryService.setSQL("
			;WITH graph
				AS (SELECT id, parent_id, child_id, ( :objectId ) as 'level', CONCAT(CAST(child_id as nvarchar(max)), ',', CAST(parent_id as nvarchar(max))) as path
					FROM object_join
					WHERE child_id = ( :objectId )
					UNION ALL
					SELECT oj.id, oj.parent_id, oj.child_id, level + ( :objectId ) as 'level', CONCAT ( path, ',', CAST(oj.parent_id as nvarchar(max))) as 'path'
					FROM object_join oj WITH (NOLOCK)
					INNER JOIN graph ON oj.child_id = graph.parent_id
					WHERE oj.parent_id NOT IN (SELECT tmp.id FROM CSVToTable(graph.path) tmp )
				)
			SELECT top 1 g.path
			FROM graph g
			WHERE EXISTS (
				SELECT 1
				FROM graph g2
				WHERE g2.parent_id = g.child_id
				AND g2.Level < g.level
			)
			AND parent_id = 1
		");
		return local.queryService.execute().getResult();
	}

	public query function searchParents(required string search, required string type) {
		local.queryService = new Query();
		local.queryService.addParam(name = 'search', value = '%#arguments.search#%', cfsqltype = 'cf_sql_varchar', null = len(arguments.search) < 2);
		local.queryService.addParam(name = 'type', value = val(arguments.type), cfsqltype = 'cf_sql_integer', null = val(arguments.type) == 0);
		local.queryService.setSQL("
			SELECT id, name, type_id
			FROM object
			WHERE name like ( :search )
				AND (( :type ) IS NULL OR type_id = ( :type ))
			ORDER BY name ASC
		");
		return local.queryService.execute().getResult();
	}

	public boolean function setObject(required string name, required numeric type, required numeric parent, numeric joinType = 1) {
		transaction {        
    	try {        
				local.queryService = new Query();
				local.queryService.addParam(name = 'name', value = trim(arguments.name), cfsqltype = 'cf_sql_varchar');
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
				local.queryService.addParam(name = 'joinType', value = arguments.joinType, cfsqltype = 'cf_sql_integer');
				local.queryService.setSQL("
					INSERT INTO object_join (parent_id, child_id, join_type_id)
					VALUES (
						( :parent ),
						( :child ),
						( :joinType )
					)
				");
				local.queryService.execute();
    		transactionCommit();
				return true;
    	} catch(any e) {
    		transactionRollback();
				return false;
    	}
    }
	}
	
	public boolean function setObjectMetaFields(required numeric objectId) {
		local.existingObjectMeta = getMetaForObject(arguments.objectId);
		local.meta = getMetaForObjectType(arguments.objectId);
		for(local.m in local.meta) {
			local.addMeta = true;
			for(local.eom in local.existingObjectMeta) {
				if(local.eom.name == local.m.name) local.addMeta = false;
			}
			if(local.addMeta) {
				local.queryService = new Query();
				local.queryService.addParam(name = 'name', value = local.m.name, cfsqltype = 'cf_sql_varchar');
				local.queryService.addParam(name = 'displayName', value = local.m.display_name, cfsqltype = 'cf_sql_varchar');
				local.queryService.addParam(name = 'typeId', value = local.m.type_id, cfsqltype = 'cf_sql_integer');
				local.queryService.addParam(name = 'objectId', value = arguments.objectId, cfsqltype = 'cf_sql_integer');
				local.queryService.addParam(name = 'sequence', value = local.m.sequence, cfsqltype = 'cf_sql_integer');
				local.queryService.addParam(name = 'multiple', value = local.m.multiple, cfsqltype = 'cf_sql_bit');
				local.queryService.setSQL("
					INSERT INTO meta (name, display_name, type_id, object_id, sequence, multiple)
					VALUES ( ( :name), ( :displayName), ( :typeId), ( :objectId), ( :sequence), ( :multiple ) )
				");
				local.queryService.execute();
			}
		}
		return true;
	}
	
	public boolean function setObjectJoinMetaFields(required numeric id, required numeric parent) {
		local.objectJoin = getObjectJoin(arguments.id, arguments.parent);
		if(local.objectJoin.recordCount) {
			local.existingObjectJoinMeta = getJoinMetaForObjectJoin(arguments.id, arguments.parent);
			local.joinMeta = getJoinMetaForObjectJoinType(arguments.id, arguments.parent);
			for(local.m in local.joinMeta) {
				local.addMeta = true;
				for(local.eom in local.existingObjectJoinMeta) {
					if(local.eom.name == local.m.name) local.addMeta = false;
				}
				if(local.addMeta) {
					local.queryService = new Query();
					local.queryService.addParam(name = 'name', value = local.m.name, cfsqltype = 'cf_sql_varchar');
					local.queryService.addParam(name = 'displayName', value = local.m.display_name, cfsqltype = 'cf_sql_varchar');
					local.queryService.addParam(name = 'joinTypeId', value = local.m.join_type_id, cfsqltype = 'cf_sql_integer');
					local.queryService.addParam(name = 'objectJoinId', value = local.objectJoin.id, cfsqltype = 'cf_sql_integer');
					local.queryService.addParam(name = 'sequence', value = local.m.sequence, cfsqltype = 'cf_sql_integer');
					local.queryService.addParam(name = 'multiple', value = local.m.multiple, cfsqltype = 'cf_sql_bit');
					local.queryService.addParam(name = 'direction', value = local.m.direction, cfsqltype = 'cf_sql_varchar', null=!len(local.m.direction));
					local.queryService.setSQL("
						INSERT INTO join_meta (name, display_name, join_type_id, object_join_id, sequence, multiple, direction)
						VALUES ( ( :name), ( :displayName), ( :joinTypeId), ( :objectJoinId), ( :sequence), ( :multiple ), ( :direction ) )
					");
					local.queryService.execute();
				}
			}
		}
		return true;
	}

	public boolean function setMetaValue(required numeric metaId, required string value, required numeric contentId, required numeric sequence) {
		local.queryService = new Query();
		local.queryService.addParam(name = 'metaId', value = arguments.metaId, cfsqltype = 'cf_sql_integer');
		local.queryService.addParam(name = 'value', value = trim(arguments.value), cfsqltype = 'cf_sql_varchar');
		local.queryService.addParam(name = 'contentId', value = arguments.contentId, cfsqltype = 'cf_sql_integer', null = arguments.contentId == 0 ? true : false);
		local.queryService.addParam(name = 'sequence', value = arguments.sequence, cfsqltype = 'cf_sql_integer');
		local.queryService.setSQL("
			INSERT INTO value (meta_id, value, content_id, sequence)
			VALUES ( ( :metaId), ( :value), ( :contentId), ( :sequence) )
		");
		local.queryService.execute();
		return true;
	}

	public boolean function setJoinMetaValue(required numeric joinMetaId, required string value, required numeric contentId, required numeric sequence) {
		local.queryService = new Query();
		local.queryService.addParam(name = 'joinMetaId', value = arguments.joinMetaId, cfsqltype = 'cf_sql_integer');
		local.queryService.addParam(name = 'value', value = trim(arguments.value), cfsqltype = 'cf_sql_varchar');
		local.queryService.addParam(name = 'contentId', value = arguments.contentId, cfsqltype = 'cf_sql_integer', null = arguments.contentId == 0 ? true : false);
		local.queryService.addParam(name = 'sequence', value = arguments.sequence, cfsqltype = 'cf_sql_integer');
		local.queryService.setSQL("
			INSERT INTO join_value (join_meta_id, value, content_id, sequence)
			VALUES ( ( :joinMetaId), ( :value), ( :contentId), ( :sequence) )
		");
		local.queryService.execute();
		return true;
	}
	
	public query function searchObjectNames(required string term, string exclude = '') {
		local.queryService = new Query();
		local.queryService.addParam(name = 'term', value = trim(arguments.term), cfsqltype = 'cf_sql_varchar');
		local.queryService.addParam(name = 'exclude', value = arguments.exclude, cfsqltype = 'cf_sql_varchar', null=arguments.exclude == '');
		local.queryService.setSQL("
			SELECT id, name, lev, (select max(id) from dbo.CSVToTable(concat( len(name), ',', len( ( :term ) )))) as x, ( :exclude ) as d
			FROM (
				SELECT id, name, dbo.levenshtein(name, ( ( :term ) ) ) AS lev, replace(name, ' ', ',') as list
				FROM object
				UNION
				SELECT object_id as id, name, dbo.levenshtein(name, ( ( :term ) ) ) AS lev, replace(name, ' ', ',') as list
				FROM alternative_names
				) AS dt
			WHERE ( ( :exclude ) is NULL OR id NOT IN ( SELECT id FROM dbo.CSVToTable(( :exclude )) ) )
			AND (
				lev <= ( SELECT max(id) * 0.25 FROM dbo.CSVToTable(concat( len(name), ',', len(( :term )))))
				OR ( :term ) IN (SELECT text FROM dbo.StringListToTable(list))
				OR charindex(( :term ), name) > 0
			)
			ORDER BY lev ASC, name ASC
		");
		return local.queryService.execute().getResult();
	}

	public boolean function deleteParent(required numeric objectId, required numeric parentId) {
		local.exists = getObjectJoin(arguments.objectId, arguments.parentId);
		if(local.exists.recordCount) {
			deleteObjectJoinMetaFields(arguments.objectId, arguments.parentId);
			local.queryService = new Query();
			local.queryService.addParam(name = 'objectId', value = arguments.objectId, cfsqltype = 'cf_sql_integer');
			local.queryService.addParam(name = 'parentId', value = arguments.parentId, cfsqltype = 'cf_sql_integer');
			local.queryService.setSQL("
				DELETE FROM object_join
				WHERE parent_id = ( :parentId )
					AND child_id = ( :objectId )
			");
			local.queryService.execute();
			return true;
		} else {
			return false;
		}
	}
	
	public boolean function setNewParent(required numeric objectId, required numeric parentId, numeric joinType = 1) {
		local.exists = getObjectJoin(arguments.objectId, arguments.parentId);
		if(!local.exists.recordCount) {
			local.queryService = new Query();
			local.queryService.addParam(name = 'objectId', value = arguments.objectId, cfsqltype = 'cf_sql_integer');
			local.queryService.addParam(name = 'parentId', value = arguments.parentId, cfsqltype = 'cf_sql_integer');
			local.queryService.addParam(name = 'joinType', value = arguments.joinType, cfsqltype = 'cf_sql_integer');
			local.queryService.setSQL("
				INSERT INTO object_join (parent_id, child_id, join_type_id)
				VALUES ( ( :parentId), ( :objectId), ( :joinType) )
			");
			local.queryService.execute();
			return true;
		} else {
			return false;
		}
	}
	
	public boolean function editObject(required numeric id, required string name, required numeric parent) {
		transaction {        
    	try {        
				local.queryService = new Query();
				local.queryService.addParam(name = 'id', value = arguments.id, cfsqltype = 'cf_sql_integer');
				local.queryService.addParam(name = 'name', value = trim(arguments.name), cfsqltype = 'cf_sql_varchar');
				local.queryService.addParam(name = 'parent', value = arguments.parent, cfsqltype = 'cf_sql_integer');
				local.queryService.setSQL("
					UPDATE object
					SET name = ( :name )
					WHERE id = ( :id )
				");
				local.queryService.execute();

				//Update meta data
				deleteObjectMetaData(arguments.id);
				setObjectMetaFields(arguments.id);
				local.objectMeta = getMetaForObject(arguments.id);
				local.sObjectMeta = {};
				for(local.meta in local.objectMeta) {
					local.sObjectMeta[local.meta.name] = local.meta.id;
				}
				local.fields = getMetaForObjectType(arguments.id);
				for(local.field in local.fields) {
					if(local.field.multiple) {
						local.i = 1;
						while(structKeyExists(arguments, "#local.field.name#_#local.i#")) {
							if(trim(arguments["#local.field.name#_#local.i#"]) != "")
								setMetaValue(local.sObjectMeta[local.field.name], arguments["#local.field.name#_#local.i#"], 0, local.i);
							local.i++;
						}
					} else {
						if(trim(arguments[local.field.name]) != "")
							setMetaValue(local.sObjectMeta[local.field.name], arguments[local.field.name], 0, 0);
					}
				}

				//Update join_meta data
				deleteObjectJoinMetaData(arguments.id, arguments.parent);
				setObjectJoinMetaFields(arguments.id, arguments.parent);
				local.objectJoinMeta = getJoinMetaForObjectJoin(arguments.id, arguments.parent);
				local.sObjectJoinMeta = {};
				for(local.joinMeta in local.objectJoinMeta) {
					local.sObjectJoinMeta[local.joinMeta.name] = local.joinMeta.id;
				}
				local.fields = getJoinMetaForObjectJoinType(arguments.id, arguments.parent);
				for(local.field in local.fields) {
					if(local.field.multiple) {
						local.i = 1;
						while(structKeyExists(arguments, "#local.field.name#_#local.i#")) {
							if(trim(arguments["#local.field.name#_#local.i#"]) != "")
								setJoinMetaValue(local.sObjectJoinMeta[local.field.name], arguments["#local.field.name#_#local.i#"], 0, local.i);
							local.i++;
						}
					} else {
						if(trim(arguments[local.field.name]) != "")
							setJoinMetaValue(local.sObjectJoinMeta[local.field.name], arguments[local.field.name], 0, 0);
					}
				}

    		transactionCommit();
				return true;
    	} catch(any e) {
    		transactionRollback();
				return false;
    	}
    }
	}

	//PRIVATE FUNCTIONS
	public struct function valueQueryToStruct(required query q) {
		local.s = {};
		if(arguments.q.recordCount) {
			structInsert(local.s, 'id', arguments.q.id);
			if(isDefined("arguments.q.name")) structInsert(local.s, 'name', arguments.q.name);
			structInsert(local.s, 'metadata', {});
			for(local.item in arguments.q) {
				if(val(local.item.multiple)) {
					local.existingValue = structKeyExists(local.s.metadata, local.item.key) ? local.s.metadata[local.item.key] : [];
					if(isArray(local.existingValue)) arrayAppend(local.existingValue, local.item.value);
					else local.existingValue = [local.s.metadata[local.item.key], local.item.value];
					local.s.metadata[local.item.key] = local.existingValue;
				}
				else structInsert(local.s.metadata, local.item.key, local.item.value);
			}
		}
		return local.s;
	}
	
}
