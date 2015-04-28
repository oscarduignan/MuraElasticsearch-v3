component {

    remote function getElasticsearchStatus(required siteid) returnFormat="json" {
        if (not siteAdminOrSuperAdmin(siteid)) return forbidden();

        return getPlugin().getStatus(siteid);
    }

    /*** utilities ***********************************************************/

    private function getMuraScope() {
        if (not isDefined("muraScope")) {
            muraScope = application.serviceFactory.getBean("MuraScope").init(isDefined("session.siteid") ? session.siteid : "");
        }
        return muraScope;
    }

    private function forbidden(message='') {
        getPageContext().getResponse().setStatus(403, 'Forbidden');
        return len(message) ? {'message'=message} : '';
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
        return listFindNoCase(memberships, 'Admin;#getBean('settingsManager').getSite(siteid).getPrivateUserPoolID()#;0') gt 0;
    }

    private function superAdmin(required memberships) {
        return listFindNoCase(memberships, 'S2') gt 0;
    }

    private function authenticated() {
        return getMuraScope().currentUser().isLoggedIn();
    }

}