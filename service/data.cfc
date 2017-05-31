component output='false' {

	public query function getAllContent() {
		local.queryService = new Query();
		local.queryService.setSQL("
			SELECT *
			FROM content
			ORDER BY id ASC
		");
		return local.queryService.execute().getResult();
	}

	public query function getAllJoinMetas() {
		local.queryService = new Query();
		local.queryService.setSQL("
			SELECT *
			FROM join_meta
		");
		return local.queryService.execute().getResult();
	}

	public query function getAllJoinTypes() {
		local.queryService = new Query();
		local.queryService.setSQL("
			SELECT *
			FROM join_type
		");
		return local.queryService.execute().getResult();
	}

	public query function getAllJoinValues() {
		local.queryService = new Query();
		local.queryService.setSQL("
			SELECT *
			FROM join_value
		");
		return local.queryService.execute().getResult();
	}

	public query function getAllMetas() {
		local.queryService = new Query();
		local.queryService.setSQL("
			SELECT *
			FROM meta
		");
		return local.queryService.execute().getResult();
	}

	public query function getAllObjects() {
		local.queryService = new Query();
		local.queryService.setSQL("
			SELECT *
			FROM object
			ORDER BY id ASC
		");
		return local.queryService.execute().getResult();
	}

	public query function getAllObjectJoins() {
		local.queryService = new Query();
		local.queryService.setSQL("
			SELECT *
			FROM object_join
		");
		return local.queryService.execute().getResult();
	}

	public query function getAllTypes() {
		local.queryService = new Query();
		local.queryService.setSQL("
			SELECT *
			FROM type
			ORDER BY id ASC
		");
		return local.queryService.execute().getResult();
	}

	public query function getAllValues() {
		local.queryService = new Query();
		local.queryService.setSQL("
			SELECT *
			FROM value
		");
		return local.queryService.execute().getResult();
	}

}
