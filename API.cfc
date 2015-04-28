component {

    remote function getIndexHistory() returnFormat="json" {

    }

    remote function getServiceStatus() returnFormat="json" {
        if (not validCSRFToken()) return badToken(); // don't need for this request but using as a test
        if (not siteAdminOrSuperAdmin(session.siteid)) return forbidden();
        return getPlugin().getStatus(session.siteid);
    }

    /*** utilities ***********************************************************/

    private function getMuraScope() {
        if (not isDefined("muraScope")) {
            muraScope = application.serviceFactory.getBean("MuraScope").init(session.siteid);
        }
        return muraScope;
    }

    private function validCSRFToken() {
        // more relaxed csrf than built in mura one - per session rather than per request
        // built off the back of the built in mura csrf protection
        var headers = getHTTPRequestData().headers;
        return (
            isDefined("session.mura.csrfsecretkey")
            and structKeyExists(headers, "X-CSRF-Token")
            and (hash(session.mura.csrfsecretkey) eq headers["X-CSRF-Token"])
        );
    }

    private function error(required code, message='') {
        getPageContext().getResponse().setStatus(code);
        return {'error'={'message'=message}};
    }

    private function badToken() {
        return error(400, 'Bad token');
    }

    private function forbidden() {
        return error(403, 'Forbidden');
    }

    private function getPlugin() {
        return getMuraScope().getBean('MuraElasticsearch');
    }

    private function getBean(required name) {
        return getPlugin().getBean(name);
    }

    private function siteAdminOrSuperAdmin(required siteid) {
        return isDefined("session.mura.memberships") and (superAdmin(session.mura.memberships) or siteAdmin(session.mura.memberships, siteid));
    }

    private function siteAdmin(required memberships, required siteid) {
        return listFind(memberships, 'Admin;#getBean('settingsManager').getSite(siteid).getPrivateUserPoolID()#;0') gt 0;
    }

    private function superAdmin(required memberships) {
        return listFind(memberships, 'S2') gt 0;
    }

}