using Godot;
using System;

public partial class Database : Resource
{
	[Export]
	public string Name { get; set; } = "Database";

	[Export]
	public string Description { get; set; } = "A simple database resource.";
}