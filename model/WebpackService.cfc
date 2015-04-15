component accessors=true {
    property name="PluginConfig";
    property name="ConfigBean";

    public function getAssetPath(required asset) {
        if (usingWebpackDevServer()) {
            return getPublicPath() & asset;
        } else {
            return getPublicPath() & getManifest()[listFirst(asset, ".")];
        }
    }

    public function getManifest() {
        return deserializeJSON(fileRead(getManifestPath()));
    }

    public function usingWebpackDevServer() {
        return not fileExists(getManifestPath());
    }

    public function getPublicPath() {
        if (usingWebpackDevServer()) {
            return "http://localhost:8080/assets/";
        } else {
            return '#getConfigBean().getContext()#/plugins/#getPluginConfig().getDirectory()#/frontend/assets/';
        }
    }

    private function getManifestPath() {
        return "../frontend/assets/manifest.json";
    }

}