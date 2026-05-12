# =========================
# EXERCISE 1 — Comment Model
# =========================

class Comment(Base):
    __tablename__ = "comments"

    id = Column(Integer, primary_key=True)
    task_id = Column(Integer, ForeignKey("tasks.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    content = Column(String(1000), nullable=False)
    created_at = Column(DateTime, server_default=func.current_timestamp())

    __table_args__ = (
        CheckConstraint("content <> ''", name="ck_comments_content_not_empty"),
    )

    task = relationship("Task", back_populates="comments")
    user = relationship("User", back_populates="comments")


# =========================
# Add relationships to existing models
# =========================

# In Task:
comments = relationship(
    "Comment",
    back_populates="task",
    cascade="all, delete-orphan"
)

# In User:
comments = relationship(
    "Comment",
    back_populates="user"
)


# =========================
# EXERCISE 2 — Migration
# =========================

command.revision(
    alembic_cfg,
    autogenerate=True,
    message="add comments table"
)

command.upgrade(alembic_cfg, "head")


# =========================
# EXERCISE 3 — CRUD
# =========================

from sqlalchemy.orm import Session

priority_rank = {
    "high": 3,
    "medium": 2,
    "low": 1
}

with Session(engine) as session:
    # Create team
    devops = Team(
        name="DevOps",
        description="Infrastructure team"
    )

    # Create user
    diana = User(
        username="diana_ops",
        email="diana@example.com",
        full_name="Diana Ops",
        team=devops
    )

    # Create tasks
    t1 = Task(
        title="CI/CD pipeline",
        status="open",
        priority="high",
        assignee=diana
    )

    t2 = Task(
        title="Monitor logs",
        status="open",
        priority="medium",
        assignee=diana
    )

    t3 = Task(
        title="Clean docker",
        status="open",
        priority="low",
        assignee=diana
    )

    session.add(devops)
    session.commit()

    # Count tasks
    print(session.query(Task).count())

    # Close one
    t1.status = "closed"
    session.commit()

    # Delete lowest priority
    tasks = session.query(Task).filter(Task.assignee == diana).all()

    lowest = min(tasks, key=lambda t: priority_rank[t.priority])
    session.delete(lowest)

    session.commit()


# =========================
# EXERCISE 4 — Rollback
# =========================

command.downgrade(alembic_cfg, "-1")