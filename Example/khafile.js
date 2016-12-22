let project = new Project('crocotile3d-viewer-kha');

project.addAssets('Assets/**');
project.addShaders('Sources/Shaders/**');

project.addLibrary('format');

// optional
// project.addLibrary('tink_json');
// project.addDefine('tink_json');
// /optional

project.addSources('..');
project.addSources('Sources');

resolve(project);
