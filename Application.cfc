component {
  this.name = 'object-explorer';
	this.datasource = 'object';
	this.enablecfoutputonly = true;

  public any function onApplicationStart() {
		//Scan service directory for service components
		local.aServices = directoryList('#getDirectoryFromPath(getCurrentTemplatePath())#service', false, 'name', '*.cfc', 'asc');

		lock scope='application' type='exclusive' timeout='10' {
			//Constants
			application.rootName = "Main";

			//Internal Functions
			application.queryToTable = queryToTable;
			application.escapeSQL = escapeSQL;

			//Services
			for(local.i=1; local.i<=arrayLen(local.aServices); local.i++) {
				if(local.aServices[local.i] != 'Application.cfc') {
					local.serviceName = listFirst(local.aServices[local.i], '.');
					application.s[local.serviceName] = new 'service.#local.serviceName#'();
				}
			}
		}
  }

  public any function onRequestStart() {
  	//For development only
		onApplicationStart();
  }
  
  public any function onRequest(required string targetPage) {
		include "./header.cfm";
		include arguments.targetPage;
		include "./footer.cfm";
  }
  
  //Internal Functions
  private string function escapeSQL(required string sql) {
  	local.escapedSql = replace(sql, "'", "''", "ALL");
  	return local.escapedSql;
  }

  private string function queryToTable(required query q, required array columns) {
		local.tableHeader = "<tr>";
		for(local.i=1; local.i <= arrayLen(arguments.columns); local.i++) {
			for(local.key in arguments.columns[i])
				local.tableHeader &= "<td>#arguments.columns[i][local.key]#</td>";
		}
		local.tableHeader &= "</tr>";
		local.tableData = "";
    for(local.d in arguments.q) {
			local.tableData &= "<tr>";
			for(local.i=1; local.i <= arrayLen(arguments.columns); local.i++) {
	      for(local.key in arguments.columns[i]) {
	        local.tableData &= "<td>#local.d[local.key]#</td>";
	      }
      }
			local.tableData &= "</tr>";
    }
		return '
			<table cellspacing="0" cellpadding="4" border="1">
				<thead>
					#local.tableHeader#
				</thead>
				<tbody>
					#local.tableData#
				</tbody>
			</table>
		';
  }
}
