{...}: {
  den.aspects.skills.homeManager = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.pablo.ai.skills;
    mattpocockSkills = pkgs.fetchFromGitHub {
      owner = "mattpocock";
      repo = "skills";
      rev = "3cca18b368ae95cdbdebbff572ccafa662551015";
      hash = "sha256-dF5i37jHnqfcXD1IRSVzSSm/pfCYSUmOsEhhs5Zx340=";
    };
    vercelSkills = pkgs.fetchFromGitHub {
      owner = "vercel-labs";
      repo = "skills";
      rev = "777599e1159e401b11ce4c8a57c20f09a8f1596e";
      hash = "sha256-lxf2ODxgwin83JHRrDynMccTFtCo+tYFb053XrS1IqA=";
    };
  in {
    options.pablo.ai.skills = {
      enable = lib.mkEnableOption "shared agent skill wiring";

      sources = lib.mkOption {
        type = lib.types.attrsOf (lib.types.oneOf [
          lib.types.path
          lib.types.str
          lib.types.package
        ]);
        default = {};
        description = "Skill name to source path. Used for ~/.agents/skills and Claude Code skills.";
      };
    };

    config = {
      pablo.ai.skills = {
        enable = true;
        sources = {
          # Engineering skills
          codebase-design = "${mattpocockSkills}/skills/engineering/codebase-design";
          diagnosing-bugs = "${mattpocockSkills}/skills/engineering/diagnosing-bugs";
          domain-modeling = "${mattpocockSkills}/skills/engineering/domain-modeling";
          grill-with-docs = "${mattpocockSkills}/skills/engineering/grill-with-docs";
          improve-codebase-architecture = "${mattpocockSkills}/skills/engineering/improve-codebase-architecture";
          prototype = "${mattpocockSkills}/skills/engineering/prototype";
          tdd = "${mattpocockSkills}/skills/engineering/tdd";
          triage = "${mattpocockSkills}/skills/engineering/triage";

          # Productivity skills
          jj-workspaces = ./jj-workspaces;
          launch-worker = ./launch-worker;
          handoff = "${mattpocockSkills}/skills/productivity/handoff";
          teach = "${mattpocockSkills}/skills/productivity/teach";
          writing-for-agents = "${mattpocockSkills}/skills/productivity/writing-for-agents";
          find-skills = "${vercelSkills}/skills/find-skills";
        };
      };

      home.file = lib.mkIf cfg.enable (
        lib.mapAttrs' (
          name: source: lib.nameValuePair ".agents/skills/${name}" {inherit source;}
        )
        cfg.sources
      );

      programs.claude-code.skills = lib.mkIf cfg.enable cfg.sources;
    };
  };
}
