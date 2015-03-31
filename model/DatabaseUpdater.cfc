component accessors=true {
    property name="BeanFactory";

    public function applyDBUpdates(required path) {
        var dbUtility = getBeanFactory().getBean("dbUtility");

        for(var update in directoryList(expandPath(path), false, "query", "*.cfm", "name asc")) {
            include path & "/" & update.name;
        }
    }
}