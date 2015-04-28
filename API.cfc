component {

    remote function getElasticsearchStatus(required siteid) returnFormat="json" {
        if (not siteAdminOrSuperAdmin(siteid)) return forbidden();

        return getPlugin().getStatus(siteid);
    }

    /*** utilities ***********************************************************/

    private function forbidden(message='') {
        getPageContext().getResponse().setStatus(403, 'Forbidden');
        return len(message) ? {'message'=message} : '';
    }

    private function getPlugin() {
        return application.serviceFactory.getBean('MuraElasticsearch');
    }

    private function getBean(required name) {
        return getPlugin().getBean(name);
    }

    private function currentUser() {
        param name="session.siteid" default="";
        return getBean("MuraScope").init(session.siteid).currentUser();
    }

    private function siteAdminOrSuperAdmin(required siteid) {
        return not isDefined("sesson.mura.memberships") or (superAdmin(session.mura.memberships) or siteAdmin(session.mura.memberships, siteid));
    }

    private function siteAdmin(required memberships, required siteid) {
        return listFind(memberships, 'Admin;#getBean('settingsManager').getSite(siteid).getPrivateUserPoolID()#;0') 
    }

    private function superAdmin(required memberships) {
        return listFind(memberships, 'S2');
    }

    private function authenticated() {
        param name="session.siteid" default="";
        return getCurrentUser().isLoggedIn();
    }

}