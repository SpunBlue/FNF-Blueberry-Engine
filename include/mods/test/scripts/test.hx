var testText:FlxText;

function createPost()
{
    testText = new FlxText(64, 24, 0, "TEST MOD - EXAMPLE SCRIPT", 24);
    testText.cameras = [camHUD];
    testText.scrollFactor.set();
    FlxG.state.add(testText);
}