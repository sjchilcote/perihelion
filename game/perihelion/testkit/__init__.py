"""Headless AI-playtest toolkit for PERIHELION: deterministic replay
recording/playback, bot policies, a bot-driven test harness, and engine
perf micro-benchmarks. See ENGINE_DESIGN.md §4."""

from .bots import AggroBot, Bot, CamperBot, ExplorerBot, PacifistBot, SteadyBot
from .harness import Result, assert_playable, run_bot, run_matrix, summarize
from .humanbot import HumanBot
from .replay import Replay, play, record

__all__ = [
    "Replay", "record", "play",
    "Bot", "AggroBot", "SteadyBot", "PacifistBot", "CamperBot", "ExplorerBot",
    "HumanBot",
    "Result", "run_bot", "run_matrix", "assert_playable", "summarize",
]
