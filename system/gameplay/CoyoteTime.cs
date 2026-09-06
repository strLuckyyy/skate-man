using Godot;
using System;

public partial class CoyoteTime : RefCounted
{
	const float COYOTE_TIME = 0.2f;
	float coyoteTimeCounter = 0.0f;
	bool isCoyoteTimeActive = false;
	GodotObject controller;

	public bool IsCoyoteTimeActive() => isCoyoteTimeActive;

	public void StartCoyoteTime(GodotObject character)
	{
		GD.Print("CoyoteTime: StartCoyoteTime called");
		controller = character.Get("controller").AsGodotObject();
		isCoyoteTimeActive = true;
		coyoteTimeCounter = 0.0f;
	}

	public void UpdateCoyoteTime(float delta)
	{
		if (!isCoyoteTimeActive) return;
		coyoteTimeCounter += delta;

		GD.Print($"CoyoteTime: UpdateCoyoteTime called, coyoteTimeCounter = {coyoteTimeCounter}");

		if (coyoteTimeCounter >= COYOTE_TIME)
		{
			isCoyoteTimeActive = false;
			controller.Set("can_jump", false);
			GD.Print("CoyoteTime: Coyote time ended, can_jump set to false");
		}
	}
}
