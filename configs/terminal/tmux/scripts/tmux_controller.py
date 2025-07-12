#!/usr/bin/env python3
import libtmux
import click
import time
import os
import sys

class TmuxController:
    def __init__(self):
        self.server = libtmux.Server()
        self.dev_session_name = 'dev'
        self.monitor_session_name = 'monitor'

    def create_dev_environment(self):
        """Create or attach to development session"""
        try:
            # Create or get dev session
            try:
                session = self.server.new_session(session_name=self.dev_session_name)
                click.echo(click.style(f"Created new session: {self.dev_session_name}", fg='green'))
            except libtmux.exc.TmuxSessionExists:
                session = self.server.find_where({'session_name': self.dev_session_name})
                click.echo(click.style(f"Attached to existing session: {self.dev_session_name}", fg='yellow'))

            # Setup main development window
            main_window = session.active_window  # Fixed: using active_window instead of attached_window
            main_window.rename_window('main')
            
            # Clear and setup main pane
            main_pane = main_window.active_pane  # Fixed: using active_pane instead of attached_pane
            main_pane.send_keys('clear')
            main_pane.send_keys('echo "🚀 Development Area"')
            
            # Create editor pane
            editor_pane = main_window.split(percent=70)  # Fixed: using percent instead of percentage
            editor_pane.send_keys('clear')
            editor_pane.send_keys('echo "📝 Editor Ready"')
            
            # Create bottom pane for git
            git_pane = editor_pane.split(percent=30)  # Fixed: using percent instead of percentage
            git_pane.send_keys('clear')
            git_pane.send_keys('git status')

            # Create servers window
            server_window = session.new_window(window_name='servers')
            server_pane1 = server_window.active_pane
            server_pane1.send_keys('clear')
            server_pane1.send_keys('echo "🌐 Server 1"')
            
            server_pane2 = server_window.split()  # Using default split
            server_pane2.send_keys('clear')
            server_pane2.send_keys('echo "🌐 Server 2"')

            # Create logs window
            logs_window = session.new_window(window_name='logs')
            logs_window.active_pane.send_keys('clear')
            logs_window.active_pane.send_keys('echo "📊 Logs Window Ready"')

            # Return to main window
            main_window.select_window()

            click.echo(click.style("\n✅ Development environment setup complete!", fg='green'))
            self._print_session_info(session)

        except Exception as e:
            click.echo(click.style(f"❌ Error creating dev environment: {e}", fg='red'))

    def create_monitoring_layout(self):
        """Create monitoring session with system info"""
        try:
            try:
                session = self.server.new_session(session_name=self.monitor_session_name)
                click.echo(click.style(f"Created new monitoring session: {self.monitor_session_name}", fg='green'))
            except libtmux.exc.TmuxSessionExists:
                session = self.server.find_where({'session_name': self.monitor_session_name})
                click.echo(click.style(f"Attached to existing monitoring session: {self.monitor_session_name}", fg='yellow'))

            # Setup monitoring window
            monitor_window = session.active_window
            monitor_window.rename_window('system')

            # Create 4-pane layout
            main_pane = monitor_window.active_pane
            main_pane.send_keys('clear')
            main_pane.send_keys('htop')

            # System info pane
            sys_pane = monitor_window.split()
            sys_pane.send_keys('clear')
            sys_pane.send_keys('watch -n 1 "df -h"')

            # Memory pane
            mem_pane = sys_pane.split()
            mem_pane.send_keys('clear')
            mem_pane.send_keys('watch -n 1 "free -m"')

            # Process pane
            proc_pane = main_pane.split()
            proc_pane.send_keys('clear')
            proc_pane.send_keys('watch -n 1 "ps aux | sort -rn -k 3 | head -n 10"')

            click.echo(click.style("\n✅ Monitoring layout created!", fg='green'))
            self._print_session_info(session)

        except Exception as e:
            click.echo(click.style(f"❌ Error creating monitoring layout: {e}", fg='red'))

    def _print_session_info(self, session):
        """Print information about the session"""
        click.echo("\n📊 Session Information:")
        click.echo(f"Session Name: {session.name}")
        click.echo("\nWindows:")
        for window in session.windows:
            click.echo(f"- {window.name} ({len(window.panes)} panes)")

    def list_sessions(self):
        """List all available tmux sessions"""
        click.echo("\n📋 Available TMux Sessions:")
        for session in self.server.sessions:
            click.echo(f"- {session.name} ({len(session.windows)} windows)")

@click.group()
def cli():
    """TMux Controller - Manage your tmux sessions"""
    pass

@cli.command()
def dev():
    """Create development environment"""
    controller = TmuxController()
    controller.create_dev_environment()

@cli.command()
def monitor():
    """Create monitoring environment"""
    controller = TmuxController()
    controller.create_monitoring_layout()

@cli.command()
def list():
    """List all tmux sessions"""
    controller = TmuxController()
    controller.list_sessions()

@cli.command()
def all():
    """Create both dev and monitoring environments"""
    controller = TmuxController()
    click.echo(click.style("🚀 TMux Controller Starting...", fg='blue'))
    click.echo("\n1. Creating Development Environment")
    controller.create_dev_environment()
    click.echo("\n2. Creating Monitoring Layout")
    controller.create_monitoring_layout()
    click.echo("\n3. Listing all sessions")
    controller.list_sessions()

if __name__ == "__main__":
    cli() 