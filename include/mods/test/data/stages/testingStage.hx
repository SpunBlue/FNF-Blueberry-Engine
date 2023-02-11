function create()
{
    getObject("stageStage").alpha = 1;
}

function update(elapsed)
{
    getObject("stageStage").alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
}

function beatHit(curBeat)
{
	if (curBeat % 4 == 0)
	{
		if (getObject("stageStage") != null)
		{
			getObject("stageStage").alpha = 1;
		}
	}
}