component output='false' {

	public query function getAllTypes() {
		local.queryService = new Query();
		local.queryService.setSQL("
			SELECT *
			FROM type
			ORDER BY id ASC
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

}
